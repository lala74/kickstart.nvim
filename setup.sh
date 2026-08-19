#!/usr/bin/env bash
#
# One-shot installer for this Neovim config.
#
#   git clone <repo> ~/.config/kickstart.nvim && ~/.config/kickstart.nvim/setup.sh
#
# Everything lands under ~/.local, so no sudo and no package manager is needed.
# The one thing this cannot provide is a C compiler and make, which tree-sitter
# needs to build parsers -- those are checked up front and reported.

set -euo pipefail

# ---------------------------------------------------------------- pinned versions

NVIM_VERSION=v0.12.3
RIPGREP_VERSION=15.2.0
FD_VERSION=v10.4.2
FZF_VERSION=v0.74.3
# 0.26.x release binaries are linked against glibc 2.39 (Ubuntu 24.04), so they
# refuse to start on anything older. 0.25.10 needs only glibc 2.29 and builds
# every parser this config uses -- verified on Ubuntu 20.04 and 22.04.
TREE_SITTER_VERSION=v0.25.10
STYLUA_VERSION=v2.5.2
NODE_VERSION=v24.19.0
GO_VERSION=go1.26.6
NERD_FONT_VERSION=v3.5.0
NERD_FONT=JetBrainsMono

# ---------------------------------------------------------------- layout

PREFIX="$HOME/.local"
BIN="$PREFIX/bin"
OPT="$PREFIX/share/kickstart-nvim"
STATE="$OPT/.versions"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

WITH_GO=1
WITH_FONT=1
DRY_RUN=0
CLEAN=0
ASSUME_YES=0

# ---------------------------------------------------------------- output

if [ -t 1 ]; then
  C_RESET=$'\033[0m'; C_BOLD=$'\033[1m'; C_RED=$'\033[31m'
  C_GREEN=$'\033[32m'; C_YELLOW=$'\033[33m'; C_BLUE=$'\033[34m'
else
  C_RESET=; C_BOLD=; C_RED=; C_GREEN=; C_YELLOW=; C_BLUE=
fi

step() { printf '%s==>%s %s%s%s\n' "$C_BLUE" "$C_RESET" "$C_BOLD" "$*" "$C_RESET"; }
info() { printf '    %s\n' "$*"; }
ok()   { printf '    %s%s%s\n' "$C_GREEN" "$*" "$C_RESET"; }
warn() { printf '    %s%s%s\n' "$C_YELLOW" "$*" "$C_RESET" >&2; }
die()  { printf '%serror:%s %s\n' "$C_RED" "$C_RESET" "$*" >&2; exit 1; }

usage() {
  cat <<'USAGE'
Usage: setup.sh [options]

  --no-go       Skip the Go toolchain (gopls will then be unavailable)
  --no-font     Skip installing the Nerd Font
  --clean       Wipe existing Neovim data/state/cache before bootstrapping
  --dry-run     Print what would happen without touching anything
  -y, --yes     Do not prompt before backing up an existing config
  -h, --help    Show this help
USAGE
}

while [ $# -gt 0 ]; do
  case "$1" in
    --no-go)    WITH_GO=0 ;;
    --no-font)  WITH_FONT=0 ;;
    --clean)    CLEAN=1 ;;
    --dry-run)  DRY_RUN=1 ;;
    -y|--yes)   ASSUME_YES=1 ;;
    -h|--help)  usage; exit 0 ;;
    *)          usage >&2; die "unknown option: $1" ;;
  esac
  shift
done

# Every filesystem- or network-touching command goes through this, so --dry-run
# is honest instead of approximate.
run() {
  if [ "$DRY_RUN" = 1 ]; then
    printf '    %s[dry-run]%s %s\n' "$C_YELLOW" "$C_RESET" "$*"
  else
    "$@"
  fi
}

have() { command -v "$1" >/dev/null 2>&1; }

# ---------------------------------------------------------------- platform

case "$(uname -s)" in
  Linux)  OS=linux;  NVIM_OS=linux;  RUST_OS=unknown-linux-musl; GO_OS=linux;  TS_OS=linux;  NODE_OS=linux;  FZF_OS=linux  ;;
  Darwin) OS=macos;  NVIM_OS=macos;  RUST_OS=apple-darwin;       GO_OS=darwin; TS_OS=macos;  NODE_OS=darwin; FZF_OS=darwin ;;
  *) die "unsupported OS: $(uname -s). This script covers Linux and macOS." ;;
esac

case "$(uname -m)" in
  x86_64|amd64)  RUST_ARCH=x86_64;  NVIM_ARCH=x86_64; GO_ARCH=amd64; TS_ARCH=x64;   NODE_ARCH=x64;   STYLUA_ARCH=x86_64 ;;
  aarch64|arm64) RUST_ARCH=aarch64; NVIM_ARCH=arm64;  GO_ARCH=arm64; TS_ARCH=arm64; NODE_ARCH=arm64; STYLUA_ARCH=aarch64 ;;
  *) die "unsupported architecture: $(uname -m). This script covers x86_64 and arm64." ;;
esac

RUST_TARGET="${RUST_ARCH}-${RUST_OS}"

# ---------------------------------------------------------------- preflight

preflight() {
step "Checking prerequisites"

local missing=()
for exe in git curl tar unzip gzip; do
  have "$exe" || missing+=("$exe")
done

# tree-sitter compiles each parser from C, and LuaSnip's jsregexp needs make.
if ! have cc && ! have gcc && ! have clang; then missing+=("a C compiler (cc/gcc/clang)"); fi
have make || missing+=("make")

if [ "$OS" = linux ]; then
  local glibc
  glibc="$(ldd --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+$' || true)"
  if [ -n "$glibc" ] && [ "$(printf '%s\n2.34\n' "$glibc" | sort -V | head -1)" != "2.34" ]; then
    printf '%serror:%s glibc %s is too old for the official Neovim %s binary (needs 2.34+).\n' \
      "$C_RED" "$C_RESET" "$glibc" "$NVIM_VERSION" >&2
    printf '    Ubuntu 20.04 and older cannot run it. Use a newer distro, a container,\n' >&2
    printf '    or build Neovim from source.\n' >&2
    exit 1
  fi
fi

# Mason builds isort and black in a virtualenv, which needs more than the bare
# python3 binary: Debian and Ubuntu split venv and pip into separate packages.
if ! have python3 || ! python3 -m venv --help >/dev/null 2>&1; then
  warn "python3 with the venv module not found -- Mason will skip isort and black"
  if [ "$OS" = linux ]; then
    warn "  install with: sudo apt-get install -y python3 python3-venv python3-pip"
  fi
fi

if [ ${#missing[@]} -gt 0 ]; then
  printf '%serror:%s missing prerequisites that cannot be installed without root:\n' "$C_RED" "$C_RESET" >&2
  for m in "${missing[@]}"; do printf '      - %s\n' "$m" >&2; done
  printf '\n    Install them first:\n' >&2
  if [ "$OS" = macos ]; then
    printf '      xcode-select --install\n' >&2
  else
    printf '      sudo apt-get install -y build-essential git curl tar unzip gzip\n' >&2
  fi
  exit 1
fi
ok "git, curl, tar, unzip, gzip, make and a C compiler are present"
}

# ---------------------------------------------------------------- download helpers

TMPDIR_SETUP=""
cleanup() {
  if [ -n "$TMPDIR_SETUP" ] && [ -d "$TMPDIR_SETUP" ]; then rm -rf "$TMPDIR_SETUP"; fi
}
trap cleanup EXIT

tmpdir() {
  if [ "$DRY_RUN" = 1 ]; then
    # Never create anything during a dry run; the path only has to look real.
    printf '%s' "${TMPDIR:-/tmp}/kickstart-setup.dry-run"
    return
  fi
  if [ -z "$TMPDIR_SETUP" ]; then
    TMPDIR_SETUP="$(mktemp -d "${TMPDIR:-/tmp}/kickstart-setup.XXXXXX")"
  fi
  printf '%s' "$TMPDIR_SETUP"
}

fetch() { # fetch <url> <dest-file>
  # A progress bar is helpful interactively and pure noise in a CI log.
  local progress=--progress-bar
  [ -t 1 ] || progress=-sS
  run curl -fL --retry 3 --retry-delay 2 --connect-timeout 20 "$progress" -o "$2" "$1" \
    || die "download failed: $1"
}

# Records the installed version so a re-run is a no-op instead of a re-download.
stamp_of() {
  if [ -f "$STATE/$1" ]; then cat "$STATE/$1"; else printf ''; fi
}

set_stamp() {
  if [ "$DRY_RUN" = 1 ]; then
    printf '    %s[dry-run]%s record %s=%s\n' "$C_YELLOW" "$C_RESET" "$1" "$2"
    return
  fi
  mkdir -p "$STATE"
  printf '%s' "$2" > "$STATE/$1"
}

# Returns 0 when the tool is already at the wanted version.
up_to_date() { # up_to_date <name> <version> <binary-path>
  [ "$(stamp_of "$1")" = "$2" ] && [ -e "$3" ]
}

install_single_binary() { # install_single_binary <name> <src-path> 
  run install -m 755 "$2" "$BIN/$1"
}

# ---------------------------------------------------------------- installers

install_nvim() {
  local bin="$OPT/nvim/bin/nvim"
  if up_to_date nvim "$NVIM_VERSION" "$bin"; then ok "neovim $NVIM_VERSION already installed"; return; fi

  local asset="nvim-${NVIM_OS}-${NVIM_ARCH}.tar.gz"
  local url="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/${asset}"
  local tmp; tmp="$(tmpdir)"

  info "neovim $NVIM_VERSION ($asset)"
  fetch "$url" "$tmp/$asset"
  run rm -rf "$OPT/nvim"
  run mkdir -p "$OPT/nvim"
  run tar -xzf "$tmp/$asset" -C "$OPT/nvim" --strip-components=1
  # Release tarballs are quarantined by Gatekeeper; without this macOS kills nvim.
  if [ "$OS" = macos ]; then run xattr -rc "$OPT/nvim" 2>/dev/null || true; fi
  run ln -sfn "$bin" "$BIN/nvim"
  set_stamp nvim "$NVIM_VERSION"
  ok "neovim installed"
}

install_ripgrep() {
  if up_to_date ripgrep "$RIPGREP_VERSION" "$BIN/rg"; then ok "ripgrep $RIPGREP_VERSION already installed"; return; fi
  local dir="ripgrep-${RIPGREP_VERSION}-${RUST_TARGET}"
  local asset="${dir}.tar.gz"
  local tmp; tmp="$(tmpdir)"
  info "ripgrep $RIPGREP_VERSION ($RUST_TARGET)"
  fetch "https://github.com/BurntSushi/ripgrep/releases/download/${RIPGREP_VERSION}/${asset}" "$tmp/$asset"
  run tar -xzf "$tmp/$asset" -C "$tmp"
  install_single_binary rg "$tmp/$dir/rg"
  set_stamp ripgrep "$RIPGREP_VERSION"
  ok "ripgrep installed"
}

install_fd() {
  # fd publishes no x86_64 macOS build; fd is optional for fzf-lua, so skip loudly.
  if [ "$OS" = macos ] && [ "$RUST_ARCH" = x86_64 ]; then
    warn "fd has no prebuilt x86_64 macOS binary -- skipping (fzf-lua falls back to 'find')"
    return
  fi
  if up_to_date fd "$FD_VERSION" "$BIN/fd"; then ok "fd $FD_VERSION already installed"; return; fi
  local dir="fd-${FD_VERSION}-${RUST_TARGET}"
  local asset="${dir}.tar.gz"
  local tmp; tmp="$(tmpdir)"
  info "fd $FD_VERSION ($RUST_TARGET)"
  fetch "https://github.com/sharkdp/fd/releases/download/${FD_VERSION}/${asset}" "$tmp/$asset"
  run tar -xzf "$tmp/$asset" -C "$tmp"
  install_single_binary fd "$tmp/$dir/fd"
  set_stamp fd "$FD_VERSION"
  ok "fd installed"
}

install_fzf() {
  if up_to_date fzf "$FZF_VERSION" "$BIN/fzf"; then ok "fzf $FZF_VERSION already installed"; return; fi
  local asset="fzf-${FZF_VERSION#v}-${FZF_OS}_${GO_ARCH}.tar.gz"
  local tmp; tmp="$(tmpdir)"
  info "fzf $FZF_VERSION"
  fetch "https://github.com/junegunn/fzf/releases/download/${FZF_VERSION}/${asset}" "$tmp/$asset"
  run tar -xzf "$tmp/$asset" -C "$tmp"
  install_single_binary fzf "$tmp/fzf"
  set_stamp fzf "$FZF_VERSION"
  ok "fzf installed"
}

install_tree_sitter() {
  # nvim-treesitter v2 shells out to this CLI to generate parsers. Using the
  # released binary is what removes the Rust/cargo dependency entirely.
  if up_to_date tree-sitter "$TREE_SITTER_VERSION" "$BIN/tree-sitter"; then
    ok "tree-sitter $TREE_SITTER_VERSION already installed"; return
  fi
  local asset="tree-sitter-${TS_OS}-${TS_ARCH}.gz"
  local tmp; tmp="$(tmpdir)"
  info "tree-sitter CLI $TREE_SITTER_VERSION"
  fetch "https://github.com/tree-sitter/tree-sitter/releases/download/${TREE_SITTER_VERSION}/${asset}" "$tmp/$asset"
  run gzip -df "$tmp/$asset"
  install_single_binary tree-sitter "$tmp/tree-sitter-${TS_OS}-${TS_ARCH}"
  set_stamp tree-sitter "$TREE_SITTER_VERSION"
  ok "tree-sitter installed"
}

install_stylua() {
  if up_to_date stylua "$STYLUA_VERSION" "$BIN/stylua"; then ok "stylua $STYLUA_VERSION already installed"; return; fi
  local asset
  if [ "$OS" = linux ]; then asset="stylua-linux-${STYLUA_ARCH}-musl.zip"; else asset="stylua-macos-${STYLUA_ARCH}.zip"; fi
  local tmp; tmp="$(tmpdir)"
  info "stylua $STYLUA_VERSION"
  fetch "https://github.com/JohnnyMorganz/StyLua/releases/download/${STYLUA_VERSION}/${asset}" "$tmp/$asset"
  run unzip -oq "$tmp/$asset" -d "$tmp/stylua-out"
  install_single_binary stylua "$tmp/stylua-out/stylua"
  set_stamp stylua "$STYLUA_VERSION"
  ok "stylua installed"
}

install_node() {
  # Mason installs pyright and bashls from npm, so node is not optional.
  if have node && [ ! -e "$OPT/node" ]; then
    ok "node already on PATH ($(node --version 2>/dev/null)) -- leaving it alone"
    return
  fi
  local bin="$OPT/node/bin/node"
  if up_to_date node "$NODE_VERSION" "$bin"; then ok "node $NODE_VERSION already installed"; return; fi
  local dir="node-${NODE_VERSION}-${NODE_OS}-${NODE_ARCH}"
  local asset="${dir}.tar.gz"
  local tmp; tmp="$(tmpdir)"
  info "node $NODE_VERSION"
  fetch "https://nodejs.org/dist/${NODE_VERSION}/${asset}" "$tmp/$asset"
  run rm -rf "$OPT/node"
  run mkdir -p "$OPT/node"
  run tar -xzf "$tmp/$asset" -C "$OPT/node" --strip-components=1
  run ln -sfn "$bin" "$BIN/node"
  run ln -sfn "$OPT/node/bin/npm" "$BIN/npm"
  run ln -sfn "$OPT/node/bin/npx" "$BIN/npx"
  set_stamp node "$NODE_VERSION"
  ok "node installed"
}

install_go() {
  if have go && [ ! -e "$OPT/go" ]; then
    ok "go already on PATH ($(go version 2>/dev/null | awk '{print $3}')) -- leaving it alone"
    return
  fi
  local bin="$OPT/go/bin/go"
  if up_to_date go "$GO_VERSION" "$bin"; then ok "go $GO_VERSION already installed"; return; fi
  local asset="${GO_VERSION}.${GO_OS}-${GO_ARCH}.tar.gz"
  local tmp; tmp="$(tmpdir)"
  info "go $GO_VERSION"
  fetch "https://go.dev/dl/${asset}" "$tmp/$asset"
  run rm -rf "$OPT/go"
  run mkdir -p "$OPT/go"
  run tar -xzf "$tmp/$asset" -C "$OPT/go" --strip-components=1
  run ln -sfn "$bin" "$BIN/go"
  run ln -sfn "$OPT/go/bin/gofmt" "$BIN/gofmt"
  set_stamp go "$GO_VERSION"
  ok "go installed"
}

install_font() {
  local dest
  if [ "$OS" = macos ]; then dest="$HOME/Library/Fonts"; else dest="$HOME/.local/share/fonts"; fi
  if up_to_date font "$NERD_FONT_VERSION" "$dest/.kickstart-${NERD_FONT}"; then
    ok "$NERD_FONT Nerd Font $NERD_FONT_VERSION already installed"; return
  fi
  local asset="${NERD_FONT}.zip"
  local tmp; tmp="$(tmpdir)"
  info "$NERD_FONT Nerd Font $NERD_FONT_VERSION"
  fetch "https://github.com/ryanoasis/nerd-fonts/releases/download/${NERD_FONT_VERSION}/${asset}" "$tmp/$asset"
  run mkdir -p "$dest/$NERD_FONT"
  run unzip -oq "$tmp/$asset" -d "$dest/$NERD_FONT" -x 'LICENSE*' 'README*'
  run touch "$dest/.kickstart-${NERD_FONT}"
  if have fc-cache; then run fc-cache -f "$dest" >/dev/null 2>&1 || true; fi
  set_stamp font "$NERD_FONT_VERSION"
  ok "font installed into $dest"
  warn "fonts are rendered by whichever terminal you actually look at; installing"
  warn "one on a remote box does nothing -- set it on your local terminal too"
}

# ---------------------------------------------------------------- shell PATH

RC_BEGIN='# >>> kickstart.nvim >>>'
RC_END='# <<< kickstart.nvim <<<'

setup_path() {
  step "Putting $BIN on PATH"
  local rcs=() rc
  if [ -f "$HOME/.bashrc" ]; then rcs+=("$HOME/.bashrc"); fi
  if [ -f "$HOME/.zshrc" ];  then rcs+=("$HOME/.zshrc");  fi
  if [ ${#rcs[@]} -eq 0 ]; then
    case "${SHELL:-}" in *zsh) rcs+=("$HOME/.zshrc") ;; *) rcs+=("$HOME/.bashrc") ;; esac
  fi

  for rc in "${rcs[@]}"; do
    if [ -f "$rc" ] && grep -qF "$RC_BEGIN" "$rc"; then
      ok "$rc already configured"
      continue
    fi
    info "appending PATH block to $rc"
    if [ "$DRY_RUN" = 1 ]; then
      printf '    %s[dry-run]%s append kickstart PATH block to %s\n' "$C_YELLOW" "$C_RESET" "$rc"
    else
      cat >> "$rc" <<RCEOF

$RC_BEGIN
case ":\$PATH:" in *":\$HOME/.local/bin:"*) ;; *) export PATH="\$HOME/.local/bin:\$PATH" ;; esac
$RC_END
RCEOF
    fi
  done
}

# ---------------------------------------------------------------- config symlink

link_config() {
  step "Linking config into $CONFIG_DIR"

  if [ "$REPO_DIR" = "$CONFIG_DIR" ]; then
    ok "repo is already the config directory"
    return
  fi
  if [ -L "$CONFIG_DIR" ] && [ "$(cd "$CONFIG_DIR" && pwd -P)" = "$REPO_DIR" ]; then
    ok "already symlinked to $REPO_DIR"
    return
  fi

  if [ -e "$CONFIG_DIR" ] || [ -L "$CONFIG_DIR" ]; then
    local backup; backup="$(unique_backup "$CONFIG_DIR")"
    warn "$CONFIG_DIR already exists and will be moved to:"
    warn "  $backup"
    if [ "$ASSUME_YES" != 1 ] && [ "$DRY_RUN" != 1 ]; then
      [ -t 0 ] || die "refusing to move $CONFIG_DIR without confirmation; re-run with --yes"
      printf '    Proceed? [y/N] '
      local reply; read -r reply
      case "$reply" in y|Y|yes|YES) ;; *) die "aborted by user" ;; esac
    fi
    run mv "$CONFIG_DIR" "$backup"
  fi

  run mkdir -p "$(dirname "$CONFIG_DIR")"
  run ln -sfn "$REPO_DIR" "$CONFIG_DIR"
  ok "$CONFIG_DIR -> $REPO_DIR"
}

unique_backup() { # unique_backup <path> -> a sibling path that does not exist yet
  local base candidate n=1
  base="$1.bak.$(date +%Y%m%d%H%M%S)"
  candidate="$base"
  while [ -e "$candidate" ]; do
    candidate="${base}.${n}"
    n=$((n + 1))
  done
  printf '%s' "$candidate"
}

clean_state() {
  step "Removing existing Neovim data (--clean)"
  local d
  for d in "$HOME/.local/share/nvim" "$HOME/.local/state/nvim" "$HOME/.cache/nvim"; do
    [ -e "$d" ] || continue
    local backup; backup="$(unique_backup "$d")"
    info "$d -> $backup"
    run mv "$d" "$backup"
  done
}

# ---------------------------------------------------------------- bootstrap

NVIM_BIN="$BIN/nvim"

nvim_headless() { # nvim_headless <description> <ex-command...>
  local desc="$1"; shift
  info "$desc"
  if [ "$DRY_RUN" = 1 ]; then
    printf '    %s[dry-run]%s %s --headless %s +qa\n' "$C_YELLOW" "$C_RESET" "$NVIM_BIN" "$*"
    return 0
  fi
  # Keep the freshly installed tools reachable even before the user re-sources
  # their shell rc.
  if ! PATH="$BIN:$PATH" "$NVIM_BIN" --headless "$@" +qa; then
    die "$desc failed"
  fi
}

bootstrap() {
  step "Bootstrapping plugins"

  # `Lazy! restore` pins every plugin to lazy-lock.json. A plain install would
  # pull each plugin's current HEAD instead, which is exactly how a fresh clone
  # ends up with a different -- and broken -- plugin set than the machine the
  # config was written on.
  nvim_headless "restoring plugins from lazy-lock.json" "+Lazy! restore"
  nvim_headless "compiling tree-sitter parsers" \
    "+lua require('nvim-treesitter').install(vim.g.kickstart_ts_parsers):wait(900000)"
  nvim_headless "installing LSP servers and formatters via Mason" "+MasonToolsInstallSync"
}

verify() {
  step "Verifying"
  if [ "$DRY_RUN" = 1 ]; then
    printf '    %s[dry-run]%s would run :checkhealth kickstart and fail on any ERROR\n' "$C_YELLOW" "$C_RESET"
    return 0
  fi

  local report; report="$(tmpdir)/health.txt"
  PATH="$BIN:$PATH" "$NVIM_BIN" --headless "+checkhealth kickstart" "+w! $report" +qa >/dev/null 2>&1 || true

  if [ ! -s "$report" ]; then
    die "checkhealth produced no output"
  fi
  if grep -q 'ERROR' "$report"; then
    printf '%serror:%s checkhealth reported problems:\n' "$C_RED" "$C_RESET" >&2
    grep -n 'ERROR' "$report" >&2
    exit 1
  fi

  local warnings; warnings="$(grep -c 'WARNING' "$report" || true)"
  if [ "${warnings:-0}" -gt 0 ]; then
    warn "$warnings warning(s) in :checkhealth kickstart (run it in Neovim to review)"
  fi
  ok "no errors in :checkhealth kickstart"

  # checkhealth says nothing about tree-sitter parsers, so a run where every
  # single parser failed to compile still looked like a success. Assert the
  # parsers exist explicitly.
  local missing
  missing="$(PATH="$BIN:$PATH" "$NVIM_BIN" --headless "+lua
    local dir = require('nvim-treesitter.config').get_install_dir('parser')
    local gone = {}
    for _, lang in ipairs(vim.g.kickstart_ts_parsers or {}) do
      if vim.fn.filereadable(dir .. '/' .. lang .. '.so') == 0 then
        table.insert(gone, lang)
      end
    end
    io.stderr:write(table.concat(gone, ' '))
  " +qa 2>&1 >/dev/null || true)"

  if [ -n "$missing" ]; then
    printf '%serror:%s tree-sitter parsers failed to build: %s\n' "$C_RED" "$C_RESET" "$missing" >&2
    printf '    The tree-sitter CLI at %s could not compile them.\n' "$BIN/tree-sitter" >&2
    printf '    Check that it runs on this machine: %s --version\n' "$BIN/tree-sitter" >&2
    exit 1
  fi
  ok "all tree-sitter parsers built"
}

summary() {
  step "Done"
  local t
  for t in nvim rg fd fzf tree-sitter stylua node go; do
    if [ -e "$BIN/$t" ] || have "$t"; then
      printf '    %-12s %s\n' "$t" "$(command -v "$t" 2>/dev/null || printf '%s' "$BIN/$t")"
    else
      printf '    %-12s %s(not installed)%s\n' "$t" "$C_YELLOW" "$C_RESET"
    fi
  done
  printf '\n'
  info "Open a new shell (or: export PATH=\"\$HOME/.local/bin:\$PATH\") and run: nvim"
}

# ---------------------------------------------------------------- main

printf '%skickstart.nvim setup%s  (%s/%s)\n\n' "$C_BOLD" "$C_RESET" "$OS" "$(uname -m)"
if [ "$DRY_RUN" = 1 ]; then warn "dry run: nothing will be modified"; fi

preflight

run mkdir -p "$BIN" "$OPT" "$STATE"

step "Installing tools into $BIN"
install_nvim
install_ripgrep
install_fd
install_fzf
install_tree_sitter
install_stylua
install_node
if [ "$WITH_GO" = 1 ]; then
  install_go
else
  warn "skipping Go (--no-go); Mason cannot build gopls without it"
fi
if [ "$WITH_FONT" = 1 ]; then
  install_font
fi

setup_path
link_config
if [ "$CLEAN" = 1 ]; then
  clean_state
fi
bootstrap
verify
summary
