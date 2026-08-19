# kickstart.nvim

## TL;DR

```sh
git clone git@github.com:lala74/kickstart.nvim.git --branch dla ~/.config/kickstart.nvim
~/.config/kickstart.nvim/setup.sh
```

That is the whole install. `setup.sh` puts everything under `~/.local`, so it
needs no `sudo` and no package manager.

## Introduction

A starting point for Neovim that is:

* Small
* Single-file
* Completely Documented

**NOT** a Neovim distribution, but instead a starting point for your configuration.

## Installation

### What `setup.sh` does

1. Checks the handful of prerequisites it *cannot* install without root, and
   tells you the exact command to fix them if any are missing.
2. Downloads pinned, prebuilt binaries into `~/.local/bin`:
   Neovim, ripgrep, fd, fzf, the tree-sitter CLI, stylua, Node, Go and a
   Nerd Font. Existing `node`/`go` already on `PATH` are reused, not replaced.
3. Adds `~/.local/bin` to `PATH` in your shell rc (guarded, so re-running is safe).
4. Symlinks the repo to `~/.config/nvim`, backing up anything already there.
5. Bootstraps plugins **from `lazy-lock.json`**, builds the tree-sitter parsers,
   and installs the LSP servers and formatters through Mason.
6. Runs `:checkhealth kickstart` and fails if anything reports an ERROR.

It is idempotent: running it again re-downloads nothing that is already at the
pinned version.

```
Usage: setup.sh [options]

  --no-go       Skip the Go toolchain (gopls will then be unavailable)
  --no-font     Skip installing the Nerd Font
  --clean       Wipe existing Neovim data/state/cache before bootstrapping
  --dry-run     Print what would happen without touching anything
  -y, --yes     Do not prompt before backing up an existing config
  -h, --help    Show this help
```

Start with `--dry-run` if you want to see the plan before anything is written.

### Prerequisites

`setup.sh` cannot install these itself, because they need root:

- `git`, `curl`, `tar`, `unzip`
- `make` and a C compiler (`cc`/`gcc`/`clang`) — tree-sitter builds every parser
  from C, so this is not optional

```sh
# Debian / Ubuntu
sudo apt-get install -y build-essential git curl tar unzip

# macOS
xcode-select --install
```

Everything else — including Neovim itself — is downloaded by the script.

### Neovim version

This config requires **Neovim 0.11 or newer** (it uses `vim.lsp.config`,
`vim.lsp.enable` and the nvim-treesitter v2 API). Distro packages are usually
far older than that, which is why `setup.sh` installs a pinned Neovim rather
than relying on whatever is on the box.

### Supported platforms

| Platform | Status |
| :------- | :----- |
| macOS 12+, arm64 and x86_64 | supported (`fd` is skipped on x86_64 -- upstream ships no build for it) |
| Ubuntu 22.04+ / glibc 2.34+, arm64 and x86_64 | supported |
| Ubuntu 20.04 and older / glibc < 2.34 | **not supported** |

The official Neovim release binaries are linked against glibc 2.34, so they
cannot run on Ubuntu 20.04 at all. `setup.sh` detects this up front and stops
with an explanation rather than failing later. Use a newer distro, a container,
or build Neovim from source there.

Two upstream gaps are worth knowing about, since Mason will report them:

- `clangd` publishes no Linux **arm64** build, so it cannot be installed on
  arm64 Linux. x86_64 Linux and macOS are fine.
- `isort` and `black` are built in a virtualenv, so they need more than the bare
  `python3` binary. On Debian and Ubuntu that means
  `sudo apt-get install -y python3 python3-venv python3-pip`; `setup.sh` warns
  when it is missing but does not treat it as fatal.

### Installing by hand

If you would rather not use the script, install the dependencies above plus
`ripgrep`, `fd`, `fzf`, the `tree-sitter` CLI and `node` (Mason needs it for
`pyright` and `bashls`), then:

```sh
git clone git@github.com:lala74/kickstart.nvim.git --branch dla "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim
nvim --headless "+Lazy! restore" +qa
```

> **Use `Lazy! restore`, not a plain start.** On a fresh clone lazy.nvim
> installs each plugin's current `HEAD`, *not* the commits recorded in
> `lazy-lock.json`. That mismatch is the single most common reason this config
> works on one machine and breaks on the next.

### Post Installation

Start Neovim:

```sh
nvim
```

Use `:Lazy` to view plugin status and `:checkhealth` to confirm the environment
is sane. Hit `q` to close either window.

### Getting Started

[The Only Video You Need to Get Started with Neovim](https://youtu.be/m8C0Cq9Uv9o)

### FAQ

* What should I do if I already have a pre-existing neovim configuration?
  * You should back it up and then delete all associated files.
  * This includes your existing init.lua and the neovim files in `~/.local`
    which can be deleted with `rm -rf ~/.local/share/nvim/`
* Can I keep my existing configuration in parallel to kickstart?
  * Yes! You can use [NVIM_APPNAME](https://neovim.io/doc/user/starting.html#%24NVIM_APPNAME)`=nvim-NAME`
    to maintain multiple configurations. For example, you can install the kickstart
    configuration in `~/.config/nvim-kickstart` and create an alias:
    ```
    alias nvim-kickstart='NVIM_APPNAME="nvim-kickstart" nvim'
    ```
    When you run Neovim using `nvim-kickstart` alias it will use the alternative
    config directory and the matching local directory
    `~/.local/share/nvim-kickstart`. You can apply this approach to any Neovim
    distribution that you would like to try out.
* What if I want to "uninstall" this configuration:
  * See [lazy.nvim uninstall](https://lazy.folke.io/usage#-uninstalling) information
* Why is the kickstart `init.lua` a single file? Wouldn't it make sense to split it into multiple files?
  * The main purpose of kickstart is to serve as a teaching tool and a reference
    configuration that someone can easily use to `git clone` as a basis for their own.
    As you progress in learning Neovim and Lua, you might consider splitting `init.lua`
    into smaller parts. A fork of kickstart that does this while maintaining the 
    same functionality is available here:
    * [kickstart-modular.nvim](https://github.com/dam9000/kickstart-modular.nvim)
  * Discussions on this topic can be found here:
    * [Restructure the configuration](https://github.com/nvim-lua/kickstart.nvim/issues/218)
    * [Reorganize init.lua into a multi-file setup](https://github.com/nvim-lua/kickstart.nvim/pull/473)

### Install Recipes

Below you can find OS specific install instructions for Neovim and dependencies.

After installing all the dependencies continue with the [Install Kickstart](#Install-Kickstart) step.

#### Windows Installation

<details><summary>Windows with Microsoft C++ Build Tools and CMake</summary>
Installation may require installing build tools and updating the run command for `telescope-fzf-native`

See `telescope-fzf-native` documentation for [more details](https://github.com/nvim-telescope/telescope-fzf-native.nvim#installation)

This requires:

- Install CMake and the Microsoft C++ Build Tools on Windows

```lua
{'nvim-telescope/telescope-fzf-native.nvim', build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build' }
```
</details>
<details><summary>Windows with gcc/make using chocolatey</summary>
Alternatively, one can install gcc and make which don't require changing the config,
the easiest way is to use choco:

1. install [chocolatey](https://chocolatey.org/install)
either follow the instructions on the page or use winget,
run in cmd as **admin**:
```
winget install --accept-source-agreements chocolatey.chocolatey
```

2. install all requirements using choco, exit previous cmd and
open a new one so that choco path is set, and run in cmd as **admin**:
```
choco install -y neovim git ripgrep wget fd unzip gzip mingw make
```
</details>
<details><summary>WSL (Windows Subsystem for Linux)</summary>

```
wsl --install
wsl
sudo add-apt-repository ppa:neovim-ppa/unstable -y
sudo apt update
sudo apt install make gcc ripgrep unzip git xclip neovim
```
</details>

#### Linux Install
<details><summary>Ubuntu Install Steps</summary>

```
sudo add-apt-repository ppa:neovim-ppa/unstable -y
sudo apt update
sudo apt install make gcc ripgrep unzip git xclip neovim
```
</details>
<details><summary>Debian Install Steps</summary>

```
sudo apt update
sudo apt install make gcc ripgrep unzip git xclip curl

# Now we install nvim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
sudo rm -rf /opt/nvim-linux64
sudo mkdir -p /opt/nvim-linux64
sudo chmod a+rX /opt/nvim-linux64
sudo tar -C /opt -xzf nvim-linux64.tar.gz

# make it available in /usr/local/bin, distro installs to /usr/bin
sudo ln -sf /opt/nvim-linux64/bin/nvim /usr/local/bin/
```
</details>
<details><summary>Fedora Install Steps</summary>

```
sudo dnf install -y gcc make git ripgrep fd-find unzip neovim
```
</details>

<details><summary>Arch Install Steps</summary>

```
sudo pacman -S --noconfirm --needed gcc make git ripgrep fd unzip neovim
```
</details>

