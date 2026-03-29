# Neovim Dotfiles

Personal Neovim configuration. Self-contained: plugins are auto-installed on first launch — no plugin manager required.

## Contents

- [Installing Neovim](#installing-neovim)
- [Requirements](#requirements)
- [Quick Start](#quick-start)
- [Updating](#updating)
- [Plugin System](#plugin-system)
- [Plugins](#plugins)
- [LSP](#lsp)
- [Key Mappings](#key-mappings)
- [Troubleshooting](#troubleshooting)

## Installing Neovim

Neovim is hot right now. Versions are coming out quickly. If newer versions are not available in your OS' default repos, you might to do something like this **Ubuntu** example:

```bash
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt update
sudo apt install neovim
```

Refer to the [original docs for other setups](https://github.com/neovim/neovim/blob/master/INSTALL.md).

## Requirements

| Tool | Purpose | Min. Version |
|------|---------|--------------|
| Neovim | Editor | 0.9+ (0.10+ for completion, 0.11+ for AI) |
| `clangd` | C/C++ LSP | any |
| `deno` | JS/TS LSP (Deno projects) | any |
| `typescript-language-server` | JS/TS LSP (Node projects) | any |
| `ripgrep` (`rg`) | Fast grep | any |
| `npm` | Required to install `mcp-hub` | any |

Install `mcp-hub` once for AI/MCP features:

```bash
npm install -g mcp-hub@latest
```

**Windows:** install tools via [scoop](https://scoop.sh), [choco](https://chocolatey.org), or [winget](https://github.com/microsoft/winget-cli).

## Quick Start

Clone as a **bare repo** into `~/.dotfiles.git`, then check out into your home directory.

**Linux / macOS / BSD / WSL / Git Bash:**

```bash
git clone --bare -b main https://github.com/quirinpa/dotfiles.git "$HOME/.dotfiles.git"
git --git-dir="$HOME/.dotfiles.git" --work-tree="$HOME" checkout
```

**PowerShell:**

```powershell
git clone --bare -b main https://github.com/quirinpa/dotfiles.git "$HOME/.dotfiles.git"
git --git-dir="$HOME/.dotfiles.git" --work-tree="$HOME" checkout
```

**CMD:**

```cmd
git clone --bare -b main https://github.com/quirinpa/dotfiles.git "%USERPROFILE%\.dotfiles.git"
git --git-dir="%USERPROFILE%\.dotfiles.git" --work-tree="%USERPROFILE%" checkout
```

Optionally suppress untracked files in `$HOME` from Git status:

```bash
git --git-dir="$HOME/.dotfiles.git" --work-tree="$HOME" config status.showUntrackedFiles no
```

Launch Neovim. Plugins are cloned automatically on first start.

## Updating

```bash
git --git-dir="$HOME/.dotfiles.git" --work-tree="$HOME" pull
```

## Plugin System

There is no external plugin manager. A small `use(repo, opts)` helper in `init.lua` clones plugins from GitHub into Neovim's native packpath (`stdpath("data")/site/pack/me/start/`) on first launch using `git clone --filter=blob:none`. Plugins load automatically via Neovim's built-in package loading.

Pinned revisions (`opts.rev`) and post-install build steps (`opts.build`) are supported.

## Plugins

| Plugin | Purpose | Min. Neovim |
|--------|---------|-------------|
| [tokyonight.nvim](https://github.com/folke/tokyonight.nvim) | Colorscheme (transparent background) | 0.9 |
| [which-key.nvim](https://github.com/folke/which-key.nvim) | Keymap hints popup | 0.9 |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Syntax highlighting, incremental selection | 0.9 |
| [mini.nvim](https://github.com/echasnovski/mini.nvim) | Extended text objects (`mini.ai`), surround (`mini.surround`) | 0.9 |
| [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | Git hunk signs, stage/reset/blame | 0.9 |
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | LSP server configurations | 0.9 |
| [blink.cmp](https://github.com/Saghen/blink.cmp) | Completion engine (LSP, snippets, buffer, path) | 0.10 |
| [copilot.lua](https://github.com/zbirenbaum/copilot.lua) | GitHub Copilot inline suggestions | 0.11 |
| [blink-cmp-copilot](https://github.com/giuxtaposition/blink-cmp-copilot) | Copilot source for blink.cmp | 0.11 |
| [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) | Lua utility library (codecompanion dependency) | 0.11 |
| [codecompanion.nvim](https://github.com/olimorris/codecompanion.nvim) | AI chat and inline assistant | 0.11 |
| [mcphub.nvim](https://github.com/ravitemer/mcphub.nvim) | MCP server management for AI context | 0.11 |
| [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim) | Floating terminal | 0.9 |

## LSP

Three language servers are configured. Each activates only when its binary is in `$PATH`.

### C / C++

`clangd` attaches to all C, C++, Objective-C, CUDA, and proto files automatically.

### JavaScript / TypeScript

The Deno and Node LSPs are mutually exclusive, selected per project based on workspace root markers:

| Server | Activates when root contains |
|--------|------------------------------|
| `denols` | `deno.json` or `deno.jsonc` |
| `ts_ls` (typescript-language-server) | `package.json`, `tsconfig.json`, or `jsconfig.json` (and no deno root) |

## Key Mappings

`<leader>` is `\` by default.

### LSP

| Mapping | Action |
|---------|--------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gi` | Go to implementation |
| `gr` | Go to references |
| `K` | Hover documentation |
| `<leader>e` | Line diagnostics (floating window) |
| `<leader>lr` | Rename symbol |
| `<leader>la` | Code actions |
| `<leader>lf` | Format buffer |

### Find / Grep

| Mapping | Action |
|---------|--------|
| `<leader>ff` | `:find` (native, searches `**`) |
| `<leader>fg` | Grep with `rg` (falls back to `vimgrep`) |
| `<leader>fb` | Buffer picker |

### Git

| Mapping | Action |
|---------|--------|
| `]c` | Next hunk |
| `[c` | Previous hunk |
| `<leader>gp` | Preview hunk |
| `<leader>gs` | Stage hunk |
| `<leader>gr` | Reset hunk |
| `<leader>gb` | Blame line |

### AI

| Mapping | Action |
|---------|--------|
| `<leader>ac` | Open AI chat |
| `<leader>aa` | AI action picker |
| `<leader>ax` | Open CLI agent (opencode) in terminal |
| `<leader>ai` | AI prompt (normal: command; visual: prompt with selection) |
| `<leader>ae` | Explain selection (visual) |
| `<leader>af` | Fix selection (visual) |
| `<leader>at` | Generate tests for selection (visual) |

Copilot suggestions (insert mode):

| Mapping | Action |
|---------|--------|
| `<M-l>` | Accept suggestion |
| `<M-]>` | Next suggestion |
| `<M-[>` | Previous suggestion |
| `<C-]>` | Dismiss suggestion |

### Terminal

| Mapping | Action |
|---------|--------|
| `<leader>t` | Toggle floating terminal |
| `<leader>x` | Horizontal split |
| `<leader>xv` | Vertical split |

### Treesitter — Incremental Selection

| Mapping | Action |
|---------|--------|
| `<leader>ss` | Start selection |
| `<leader>si` | Expand selection by one node |
| `<leader>sd` | Shrink selection by one node |

### Surround (mini.surround)

| Mapping | Action |
|---------|--------|
| `ys{motion}{char}` | Add surround |
| `ds{char}` | Delete surround |
| `cs{old}{new}` | Replace surround |
| `<leader>sf` | Find surround (right) |
| `<leader>sF` | Find surround (left) |
| `<leader>sh` | Highlight surround |

## Troubleshooting

### `git checkout` fails during setup

Conflicting files already exist in your home directory. Inspect them:

```bash
git --git-dir="$HOME/.dotfiles.git" --work-tree="$HOME" checkout 2>&1 | grep "^\s"
```

Back up or remove the listed files, then run checkout again.

### LSP does not attach

- Confirm the server binary is in `$PATH` (e.g. `which clangd`, `which deno`).
- For JS/TS: ensure the correct root marker exists (`deno.json` for Deno, `package.json` for Node).
- Run `:checkhealth lsp` to inspect server state.

### Completion or AI features not available

- `blink.cmp` requires Neovim 0.10+.
- Copilot, CodeCompanion, and MCP Hub require Neovim 0.11+.
- On first launch, plugins are cloned synchronously before Neovim finishes starting. If a clone fails, check `:messages` for errors. Plugins are installed into `stdpath("data")/site/pack/me/start/` — you can inspect or remove entries there manually.

### Copilot not working

Run `:Copilot auth` to authenticate with GitHub if you have not done so already.
