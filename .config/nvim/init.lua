-- basic options {{{
-- vim: fdm=marker

vim.opt.clipboard = "unnamedplus"
vim.o.autoread = true

vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.expandtab = true
vim.opt.smarttab = true
vim.opt.breakindent = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2

vim.opt.winblend = 12
vim.opt.pumblend = 12

vim.opt.fileformats = { "unix", "dos" }
vim.opt.fileformat = "unix"

local USE_COPILOT_COMPLETION = true

-- }}}
-- self-contained plugin system {{{
local uv = vim.uv or vim.loop

local function run(cmd)
  local out = vim.fn.system(cmd)
  if vim.v.shell_error ~= 0 then
    error(("command failed in %s:\n%s"):format(vim.fn.getcwd(), out))
  end
end

local function use(repo, opt)
  opt = opt or {}

  local name = repo:match(".*/(.*)")
  local kind = opt.opt and "opt" or "start"
  local path = vim.fn.stdpath("data") .. "/site/pack/me/" .. kind .. "/" .. name

  local just_installed = false

  if not uv.fs_stat(path) then
    vim.api.nvim_out_write("Installing " .. repo .. "...\n")
    vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
    run({
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/" .. repo .. ".git",
      path,
    })

    if opt.rev then
      local old = vim.fn.getcwd()
      vim.cmd("cd " .. vim.fn.fnameescape(path))
      run({ "git", "checkout", opt.rev })
      vim.cmd("cd " .. vim.fn.fnameescape(old))
    end

    vim.cmd("packadd " .. name)
    just_installed = true
  end

  if opt.build and just_installed then
    vim.api.nvim_out_write("Building " .. repo .. "...\n")
    local old = vim.fn.getcwd()
    vim.cmd("cd " .. vim.fn.fnameescape(path))
    run(type(opt.build) == "function" and opt.build(path) or opt.build)
    vim.cmd("cd " .. vim.fn.fnameescape(old))
  end

  return path
end

local function req(mod)
  local ok, lib = pcall(require, mod)
  return ok and lib or nil
end
-- }}}
-- utilities {{{
local map = vim.keymap.set

local function exists(path)
  return uv.fs_stat(path) ~= nil
end

local function is_executable(bin)
  return vim.fn.executable(bin) == 1
end

local function first_executable(...)
  for i = 1, select("#", ...) do
    local x = select(i, ...)
    if x and x ~= "" then
      if x:find("/") then
        if exists(x) then
          return x
        end
      elseif is_executable(x) then
        return x
      end
    end
  end
end

local function require_executable(bin, msg)
  local exe = first_executable(bin)
  if exe then
    return exe
  end

  local text = ("missing executable: %s"):format(bin)
  if msg and msg ~= "" then
    text = "skipped loading" .. text .. ": " .. msg
  end

  vim.notify(text, vim.log.levels.WARN, { title = "init.lua" })
  return nil
end

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "init.lua" })
end

local function nvim_at_least(major, minor, patch)
  local v = vim.version()
  local cur = (v.major * 10000) + (v.minor * 100) + (v.patch or 0)
  local req = (major * 10000) + (minor * 100) + (patch or 0)
  return cur >= req
end

local function require_nvim(major, minor, patch, msg)
  if nvim_at_least(major, minor, patch) then
    return true
  end

  local text = ("nvim < %d.%d.%d"):format(major, minor, patch)
  if msg and msg ~= "" then
    text = text .. ": skipped " .. msg
  end
  vim.notify(text, vim.log.levels.WARN, { title = "init.lua" })
  return false
end

-- }}}
-- colorscheme {{{

use("folke/tokyonight.nvim")
local tokyonight = req("tokyonight")
if tokyonight then
  tokyonight.setup({
    transparent = true,
    styles = {
      sidebars = "transparent",
      floats = "dark",
    },
  })

  vim.cmd.colorscheme("tokyonight")
  vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
  vim.api.nvim_set_hl(0, "NonText", { bg = "none" })
end

-- }}}
-- which-key {{{
use("folke/which-key.nvim")
local wk = req("which-key")
if wk then
  wk.setup({
    preset = "modern",
    delay = 200,
    win = { border = "rounded" },
    layout = { spacing = 6 },
    sort = { "local", "order", "group", "alphanum", "mod" },

    icons = {
      mappings = false,
    },

    replace = {
      key = {
        function(key)
          return key
            :gsub("<Space>", "SPC")
            :gsub("<CR>", "Enter")
            :gsub("<Esc>", "Esc")
            :gsub("<Tab>", "Tab")
            :gsub("<BS>", "BS")
            :gsub("<Up>", "Up")
            :gsub("<Down>", "Down")
            :gsub("<Left>", "Left")
            :gsub("<Right>", "Right")
            :gsub("<C%-(.-)>", "Ctrl+%1")
            :gsub("<M%-(.-)>", "Alt+%1")
            :gsub("<S%-(.-)>", "Shift+%1")
        end,
      },
    },

    spec = {
      { "<leader>f", group = "find" },
      { "<leader>g", group = "git" },
      { "<leader>l", group = "lsp" },
      { "<leader>a", group = "ai" },

      { "<leader>e", desc = "line diagnostics" },

      { "<leader>ff", desc = "find files" },
      { "<leader>fg", desc = "live grep" },
      { "<leader>fb", desc = "buffers" },
      { "<leader>fh", desc = "help tags" },

      { "<leader>ac", desc = "chat" },
      { "<leader>aa", desc = "actions" },
      { "<leader>ai", desc = "inline" },
      { "<leader>ae", desc = "explain selection", mode = "v" },
      { "<leader>af", desc = "fix selection", mode = "v" },
      { "<leader>at", desc = "test selection", mode = "v" },
    },
  })
end

local function nmap(lhs, rhs, desc)
  map("n", lhs, rhs, { desc = desc })
end

-- }}}
-- treesitter {{{
use("nvim-treesitter/nvim-treesitter")
local ts = req("nvim-treesitter.configs")
if ts then
  ts.setup({
    ensure_installed = {
      "lua",
      "vim",
      "vimdoc",
      "query",
      "javascript",
      "typescript",
      "tsx",
      "c",
      "cpp",
    },
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },
    indent = {
      enable = true,
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<leader>ss",
        node_incremental = "<leader>si",
        node_decremental = "<leader>sd",
        scope_incremental = false,
      },
    },
  })
end
-- }}}
-- mini.nvim {{{
use("nvim-mini/mini.nvim")

local mini_ai = req("mini.ai")
if mini_ai then
  mini_ai.setup({
    n_lines = 500,
  })
end

local mini_surround = req("mini.surround")
if mini_surround then
  mini_surround.setup({
  mappings = {
    add = "ys",
    delete = "ds",
    replace = "cs",
    find = "<leader>sf",
    find_left = "<leader>sF",
    highlight = "<leader>sh",
    update_n_lines = "",
  },
})
end
-- }}}
-- blink / completion {{{

local blink = nil
local lsp_capabilities = vim.lsp.protocol.make_client_capabilities()

if require_nvim(0, 10, 0, "loading blink") then
  use("Saghen/blink.cmp")

  if USE_COPILOT_COMPLETION then
    use("giuxtaposition/blink-cmp-copilot")
  end

  blink = req("blink.cmp")
  if blink then
    lsp_capabilities = blink.get_lsp_capabilities()
  end
end

--- }}}
-- lsp stuff {{{
-- lsp mappings {{{
local on_attach = function(_, bufnr)
  local function bufmap(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
  end

  bufmap("n", "gd", vim.lsp.buf.definition, "LSP definition")
  bufmap("n", "gD", vim.lsp.buf.declaration, "LSP declaration")
  bufmap("n", "gi", vim.lsp.buf.implementation, "LSP implementation")
  bufmap("n", "gr", vim.lsp.buf.references, "LSP references")
  bufmap("n", "K", vim.lsp.buf.hover, "LSP hover")
  bufmap("n", "<leader>lr", vim.lsp.buf.rename, "LSP rename")
  bufmap({ "n", "x" }, "<leader>la", vim.lsp.buf.code_action, "LSP code action")
  bufmap("n", "<leader>lf", function()
    vim.lsp.buf.format({ async = true })
  end, "LSP format")
end

nmap("<leader>e", vim.diagnostic.open_float, "Line diagnostics")

local ts_ls_cmd = require_executable("typescript-language-server", "ts_ls lsp configuration")
local deno_cmd = require_executable("deno", "deno lsp configuration")
local clangd_cmd = require_executable("clangd", "clangd lsp configuration")
-- }}}
-- lsp compat helper {{{
local lspconfig_spec = nvim_at_least(0, 10, 0) and {} or { rev = "v0.1.8" }

use("neovim/nvim-lspconfig", lspconfig_spec)
local has_new_lsp = type(vim.lsp.config) == "function"
local lspconfig = not has_new_lsp and req("lspconfig") or nil
local ts_server_name = has_new_lsp and "ts_ls" or "tsserver"

local function setup_lsp(name, config)
  if has_new_lsp then
    vim.lsp.config(name, config)
    vim.lsp.enable(name)
    return true
  end

  if lspconfig and lspconfig[name] then
    lspconfig[name].setup(config)
    return true
  end

  notify("LSP setup failed for " .. name, vim.log.levels.WARN)
  return false
end

-- }}}
-- lsp lang specifics {{{
-- deno {{{
if deno_cmd then
  setup_lsp("denols", {
    cmd = { deno_cmd, "lsp" },
    filetypes = {
      "typescript",
      "javascript",
      "typescriptreact",
      "javascriptreact",
    },
    root_dir = function(bufnr, on_dir)
      local root = vim.fs.root(bufnr, { "deno.json", "deno.jsonc" })
      if root then
        if has_new_lsp then
          on_dir(root)
        else
          return root
        end
      end
    end,
    capabilities = lsp_capabilities,
    on_attach = on_attach,
  })
else
  notify("denols not enabled: missing deno", vim.log.levels.WARN)
end
-- }}}
-- typescript {{{
if ts_ls_cmd then
  setup_lsp(ts_server_name, {
    cmd = { ts_ls_cmd, "--stdio" },
    filetypes = {
      "typescript",
      "javascript",
      "typescriptreact",
      "javascriptreact",
    },
    root_dir = function(bufnr, on_dir)
      local deno_root = vim.fs.root(bufnr, { "deno.json", "deno.jsonc" })
      if deno_root then
        return
      end

      local root = vim.fs.root(bufnr, {
        "package.json",
        "tsconfig.json",
        "jsconfig.json",
      })

      if root then
        if has_new_lsp then
          on_dir(root)
        else
          return root
        end
      end
    end,
    single_file_support = false,
    capabilities = lsp_capabilities,
    on_attach = on_attach,
  })
else
  notify("ts_ls not enabled: missing typescript-language-server and/or node", vim.log.levels.WARN)
end
-- }}}
-- clangd {{{
if clangd_cmd then
  setup_lsp("clangd", {
    cmd = { clangd_cmd },
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
    capabilities = lsp_capabilities,
    on_attach = on_attach,
  })
else
  notify("clangd not enabled: missing clangd", vim.log.levels.WARN)
end
-- }}}
-- }}}
-- }}}
-- find and grep {{{
vim.opt.path = { ".", "**" }

vim.keymap.set("n", "<leader>ff", ":find ", { desc = "Find files" })

if vim.fn.executable("rg") == 1 then
  vim.opt.grepprg = "rg --vimgrep --smart-case"
  vim.opt.grepformat = "%f:%l:%c:%m"
else
  notify("ripgrep not found in PATH", vim.log.levels.WARN)
end

if vim.fn.executable("rg") == 1 then
  vim.opt.grepprg = "rg --vimgrep --smart-case"
  vim.opt.grepformat = "%f:%l:%c:%m"

  nmap("<leader>fg", function()
    local pat = vim.fn.input("Grep > ")
    if pat == "" then
      return
    end
    vim.cmd("grep! " .. vim.fn.shellescape(pat))
    vim.cmd("copen")
  end, "Grep files")
else
  nmap("<leader>fg", function()
    local pat = vim.fn.input("Grep > ")
    if pat == "" then
      return
    end
    vim.cmd("silent vimgrep /" .. vim.fn.escape(pat, "/\\") .. "/gj **/*")
    vim.cmd("copen")
  end, "Grep files")
end

nmap("<leader>fb", function()
  local buffers = vim.fn.getbufinfo({ buflisted = 1 })
  vim.ui.select(buffers, {
    prompt = "Buffers",
    format_item = function(buf)
      return string.format("%d: %s", buf.bufnr, buf.name ~= "" and buf.name or "[No Name]")
    end,
  }, function(choice)
    if choice then
      vim.cmd("buffer " .. choice.bufnr)
    end
  end)
end, "Buffers")

-- }}}
-- gitsigns {{{
local gitsigns_spec = nvim_at_least(0, 10, 0) and {} or { rev = "v1.0.2" }
use("lewis6991/gitsigns.nvim", gitsigns_spec)

local gitsigns = req("gitsigns")
if gitsigns then
  gitsigns.setup({
    on_attach = function(bufnr)
      local gs = require("gitsigns")

      local function bufmap(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
      end

      bufmap("n", "]c", function()
        if vim.wo.diff then
          vim.cmd.normal({ "]c", bang = true })
        else
          gs.nav_hunk("next")
        end
      end, "Next hunk")

      bufmap("n", "[c", function()
        if vim.wo.diff then
          vim.cmd.normal({ "[c", bang = true })
        else
          gs.nav_hunk("prev")
        end
      end, "Previous hunk")

      bufmap("n", "<leader>gp", gs.preview_hunk, "Preview hunk")
      bufmap("n", "<leader>gs", gs.stage_hunk, "Stage hunk")
      bufmap("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
      bufmap("n", "<leader>gb", gs.blame_line, "Blame line")
    end,
  })
end
-- }}}
-- copilot {{{
if USE_COPILOT_COMPLETION and require_nvim(0, 11, 0, "loading copilot") then
  use("zbirenbaum/copilot.lua")

  local copilot = req("copilot")
  if copilot then
    copilot.setup({
      suggestion = {
        enabled = false,
      },
      panel = {
        enabled = false,
      },
      copilot_node_command = "node",
    })
  end
end

-- }}}
-- codecompanion {{{
if require_nvim(0, 11, 0, "loading codecompanion") then
  use("nvim-lua/plenary.nvim")
  use("olimorris/codecompanion.nvim")
  local codecompanion = req("codecompanion")
  if codecompanion then
    local extensions = {}

    codecompanion.setup({
      interactions = {
        chat = { adapter = "opencode", variables = {} },
        inline = { adapter = "copilot" }, -- only if you want inline HTTP adapter behavior
        cli = {
          agent = "opencode",
          agents = {
            opencode = {
              cmd = "opencode",
              args = {},
              description = "opencode cli",
              provider = "terminal",
            },
          },
        },
      },
    })

    map("n", "<leader>ac", "<cmd>CodeCompanionChat<cr>", { desc = "AI chat" })
    map("n", "<leader>aa", "<cmd>CodeCompanionActions<cr>", { desc = "AI actions" })
    map("n", "<leader>ax", "<cmd>CodeCompanionCLI<cr>", { desc = "AI CLI" })

    map("v", "<leader>ai", ":CodeCompanion ", { desc = "AI Selection" })
    map("n", "<leader>ai", ":CodeCompanion ", { desc = "AI Command" })

    map("v", "<leader>ae", ":CodeCompanion explain<CR>", { desc = "AI explain selection" })
    map("v", "<leader>af", ":CodeCompanion fix<CR>", { desc = "AI fix selection" })
    map("v", "<leader>at", ":CodeCompanion test<CR>", { desc = "AI test selection" })
end
end

-- }}}
-- blink.cmp {{{

if blink then
  local sources = { "lsp", "path", "snippets", "buffer" }
  local providers = {}

  if USE_COPILOT_COMPLETION then
    table.insert(sources, "copilot")
    providers.copilot = {
      name = "copilot",
      module = "blink-cmp-copilot",
      score_offset = 100,
      async = true,
    }
  end

  blink.setup({
    sources = {
      default = sources,
      providers = providers,
    },
    fuzzy = {
      implementation = "lua",
    },
  })
end
-- }}}
-- toggleterm {{{
use("akinsho/toggleterm.nvim")
local toggleterm = require('toggleterm')
if toggleterm then
  toggleterm.setup({
    start_in_insert = true,
    close_on_exit = true,
    persist_mode = false,
  })
end

vim.keymap.set("n", "<leader>t", "<cmd>ToggleTerm<CR>", { desc = "Toggle terminal" })
vim.keymap.set("n", "<leader>x", "<cmd>sp<CR>", { desc = "Horizontal Split" })
vim.keymap.set("n", "<leader>xv", "<cmd>vsp<CR>", { desc = "Vertical Split" })

-- }}}
-- windows quirks {{{
if vim.fn.has("win32") == 1 then
  vim.opt.shell = "powershell.exe"
  vim.opt.shellcmdflag =
    "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command " ..
    "[Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();" ..
    "$PSDefaultParameterValues['Out-File:Encoding']='utf8';"

  vim.opt.shellpipe = "> %s 2>&1"
  vim.opt.shellredir = "> %s 2>&1"
  vim.opt.shellquote = ""
  vim.opt.shellxquote = ""
  vim.opt.shelltemp = false

  vim.opt.rtp:append(vim.fn.expand("~/bin"))

  vim.opt.guifont = "Consolas:h16"
end
-- }}}
