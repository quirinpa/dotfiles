# Dotfiles

Personal dotfiles for Vim and Neovim.

## Quick Start

Clone the repository as a **bare repo** into `~/.dotfiles.git`, then check it out into your home directory:

```bash
git clone --bare --recurse-submodules -b main https://github.com/quirinpa/dotfiles.git "$HOME/.dotfiles.git"
git --git-dir="$HOME/.dotfiles.git" --work-tree="$HOME" checkout
git --git-dir="$HOME/.dotfiles.git" --work-tree="$HOME" submodule update --init --recursive
```

Optional: hide untracked files in `$HOME` from Git status output:

```bash
git --git-dir="$HOME/.dotfiles.git" --work-tree="$HOME" config status.showUntrackedFiles no
```

This keeps the Git repository in `~/.dotfiles.git` while checking files out directly into your home directory.

Works on Linux, macOS, BSD, and Windows (PowerShell, CMD, Git Bash, or WSL), with the appropriate home directory variable.

### Windows examples

**PowerShell:**

```powershell
git clone --bare --recurse-submodules -b main https://github.com/quirinpa/dotfiles.git "$HOME/.dotfiles.git"
git --git-dir="$HOME/.dotfiles.git" --work-tree="$HOME" checkout
git --git-dir="$HOME/.dotfiles.git" --work-tree="$HOME" config status.showUntrackedFiles no
```

**CMD:**

```cmd
git clone --bare --recurse-submodules -b main https://github.com/quirinpa/dotfiles.git "%USERPROFILE%\.dotfiles.git"
git --git-dir="%USERPROFILE%\.dotfiles.git" --work-tree="%USERPROFILE%" checkout
git --git-dir="%USERPROFILE%\.dotfiles.git" --work-tree="%USERPROFILE%" config status.showUntrackedFiles no
```

## Updating

To pull the latest changes:

```bash
git --git-dir="$HOME/.dotfiles.git" --work-tree="$HOME" pull --recurse-submodules
```

## Requirements

* Vim 8+ or Neovim
* `ag` (the silver searcher)
* `clangd` (for C/C++ LSP)
* `deno` or `typescript-language-server` (for JS/TS LSP)

**Windows:** Install dependencies via [scoop](https://scoop.sh), [choco](https://chocolatey.org), or [winget](https://github.com/microsoft/winget-cli).

## Features

### LSP Server Toggle

Switch between **deno lsp** and **typescript-language-server** for JavaScript/TypeScript.

**Default:** deno

**Change default via environment variable:**

```bash
LSP_SERVER=ts vim
```

**Switch at runtime:**

```vim
:ToggleLspServer
```

Or use the keymap `\ls` in normal mode.

### Key Mappings

| Mapping     | Action                       |
| ----------- | ---------------------------- |
| `<leader>*` | Search for word under cursor |
| `<leader>g` | Open Grepper                 |
| `\ls`       | Toggle LSP server            |

### Plugins

**Vim:**

* [vim-commentary](https://github.com/tpope/vim-commentary) - Comment stuff
* [vim-eslint-compiler](https://github.com/salomvary/vim-eslint-compiler) - ESLint compiler
* [vim-fugitive](https://github.com/tpope/vim-fugitive) - Git integration
* [vim-grepper](https://github.com/mhinz/vim-grepper) - Grep front-end
* [vim-lsc](https://github.com/natebosch/vim-lsc) - LSP client
* [vim-signify](https://github.com/mhinz/vim-signify) - Git diff in gutter

**Neovim:**

* [snacks.nvim](https://github.com/folke/snacks.nvim) - Dashboard, explorer, etc.
* [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) - Fuzzy finder
* [tokyonight.nvim](https://github.com/folke/tokyonight.nvim) - Theme
* [opencode.nvim](https://github.com/nickjvandyke/opencode.nvim) - Opencode integration

## Troubleshooting

### `git checkout` fails during setup

If checkout fails, you probably already have files in your home directory that would be overwritten.

Inspect the conflict list with:

```bash
git --git-dir="$HOME/.dotfiles.git" --work-tree="$HOME" checkout
```

Back up or remove conflicting files, then run checkout again.

### LSP features do not work

* Ensure required binaries are in your `$PATH`
* Check `:LscServerStatus` for server status
* Set `LSP_SERVER=ts` if you prefer `typescript-language-server`
