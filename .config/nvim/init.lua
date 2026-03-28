-- basic options {{{

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

-- }}}
-- self-contained plugin system {{{
local uv = vim.uv or vim.loop

local function run(cmd, cwd)
  local out = vim.fn.system(cmd)
  if vim.v.shell_error ~= 0 then
    error(("command failed in %s:\n%s"):format(cwd or vim.fn.getcwd(), out))
  end
end

local function use(repo, opt)
  opt = opt or {}

  local name = repo:match(".*/(.*)")
  local kind = opt.opt and "opt" or "start"
  local path = vim.fn.stdpath("data") .. "/site/pack/me/" .. kind .. "/" .. name

  local just_installed = false

  if not uv.fs_stat(path) then
    vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
    run({
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/" .. repo .. ".git",
      path,
    }, path)
    just_installed = true
  end

  if opt.build and just_installed then
    local old = vim.fn.getcwd()
    vim.cmd("cd " .. vim.fn.fnameescape(path))
    run(type(opt.build) == "function" and opt.build(path) or opt.build, path)
    vim.cmd("cd " .. vim.fn.fnameescape(old))
  end

  return path
end

local function req(mod)
  local ok, lib = pcall(require, mod)
  return ok and lib or nil
end
-- }}}

use("folke/tokyonight.nvim")
use("folke/which-key.nvim")
use("nvim-lua/plenary.nvim")
use("nvim-telescope/telescope.nvim")
use("lewis6991/gitsigns.nvim")
use("neovim/nvim-lspconfig")
use("nvim-treesitter/nvim-treesitter")
use("nvim-mini/mini.nvim")

-- Mason for external tool bootstrap
use("mason-org/mason.nvim")
use("mason-org/mason-lspconfig.nvim")

-- Completion
use("Saghen/blink.cmp")
use("giuxtaposition/blink-cmp-copilot")

-- AI
use("zbirenbaum/copilot.lua")
use("olimorris/codecompanion.nvim")
use("ravitemer/mcphub.nvim", {
  build = { "npm", "install", "-g", "mcp-hub@latest" },
})

-- utilities {{{
local map = vim.keymap.set

local function exists(path)
  return uv.fs_stat(path) ~= nil
end

local function is_executable(bin)
  return vim.fn.executable(bin) == 1
end

local function mason_bin(name)
  local p = vim.fn.stdpath("data") .. "/mason/bin/" .. name
  return exists(p) and p or nil
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

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "init.lua" })
end

-- }}}
-- colorscheme {{{

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
local mini_ai = req("mini.ai")
if mini_ai then
  mini_ai.setup({
    n_lines = 500,
  })
end

local mini_surround = req("mini.surround")
if mini_surround then
  mini_surround.setup()
  require("mini.surround").setup({
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
-- lsp {{{

local blink = req("blink.cmp")
local blink_capabilities = blink and blink.get_lsp_capabilities() or vim.lsp.protocol.make_client_capabilities()

local on_attach = function(_, bufnr)
  local function bufmap(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
  end

  if wk then
    wk.add({
      { "<leader>l", group = "lsp", buffer = bufnr },
      { "<leader>la", desc = "code action", buffer = bufnr, mode = { "n", "x" } },
      { "<leader>lf", desc = "format", buffer = bufnr },
      { "<leader>lr", desc = "rename", buffer = bufnr },
    })
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

--- }}}
-- Mason {{{
local mason = req("mason")
local mason_lspconfig = req("mason-lspconfig")

if mason then
  mason.setup()
end

if mason_lspconfig then
  mason_lspconfig.setup({
    ensure_installed = {
      "ts_ls",
      "clangd",
    },
    automatic_enable = false,
  })
end

-- Use Mason-installed binaries if present, otherwise PATH
local ts_ls_cmd = first_executable(
  mason_bin("typescript-language-server"),
  "typescript-language-server"
)

local clangd_cmd = first_executable(
  mason_bin("clangd"),
  "clangd"
)

if ts_ls_cmd and first_executable(mason_bin("node"), "node") then
  vim.lsp.config("ts_ls", {
    cmd = { ts_ls_cmd, "--stdio" },
    filetypes = {
      "typescript",
      "javascript",
      "typescriptreact",
      "javascriptreact",
    },
    capabilities = blink_capabilities,
    on_attach = on_attach,
  })
  vim.lsp.enable("ts_ls")
else
  notify("ts_ls not enabled: missing typescript-language-server and/or node", vim.log.levels.WARN)
end

if clangd_cmd then
  vim.lsp.config("clangd", {
    cmd = { clangd_cmd },
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
    capabilities = blink_capabilities,
    on_attach = on_attach,
  })
  vim.lsp.enable("clangd")
else
  notify("clangd not enabled: missing clangd", vim.log.levels.WARN)
end

-- }}}
-- telescope {{{

local builtin = req("telescope.builtin")
if builtin then
  nmap("<leader>ff", builtin.find_files, "Find files")
  nmap("<leader>fg", builtin.live_grep, "Live grep")
  nmap("<leader>fb", builtin.buffers, "Buffers")
  nmap("<leader>fh", builtin.help_tags, "Help tags")
end

-- }}}
-- gitsigns {{{

local gitsigns = req("gitsigns")
if gitsigns then
  gitsigns.setup({
    on_attach = function(bufnr)
      local gs = require("gitsigns")

      local function bufmap(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
      end

      if wk then
        wk.add({
          { "<leader>g", group = "git", buffer = bufnr },
          { "<leader>gp", desc = "preview hunk", buffer = bufnr },
          { "<leader>gs", desc = "stage hunk", buffer = bufnr },
          { "<leader>gr", desc = "reset hunk", buffer = bufnr },
          { "<leader>gb", desc = "blame line", buffer = bufnr },
        })
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

local copilot = req("copilot")
if copilot then
  copilot.setup({
    panel = {
      enabled = true,
      auto_refresh = false,
      keymap = {
        jump_prev = "[[",
        jump_next = "]]",
        accept = "<CR>",
        refresh = "gr",
        open = "<M-CR>",
      },
      layout = {
        position = "bottom",
        ratio = 0.4,
      },
    },

    suggestion = {
      enabled = true,
      auto_trigger = false,
      hide_during_completion = true,
      debounce = 15,
      trigger_on_accept = true,
      keymap = {
        accept = "<M-l>",
        accept_word = false,
        accept_line = false,
        next = "<M-]>",
        prev = "<M-[>",
        dismiss = "<C-]>",
        toggle_auto_trigger = false,
      },
    },

    nes = {
      enabled = false,
      auto_trigger = false,
      keymap = {
        accept_and_goto = false,
        accept = false,
        dismiss = false,
      },
    },

    logger = {
      file = vim.fn.stdpath("log") .. "/copilot-lua.log",
      file_log_level = vim.log.levels.OFF,
      print_log_level = vim.log.levels.WARN,
      trace_lsp = "off",
      trace_lsp_progress = false,
      log_lsp_messages = false,
    },

    copilot_node_command = first_executable(mason_bin("node"), "node") or "node",

    root_dir = function()
      local git = vim.fs.find(".git", { upward = true })[1]
      return git and vim.fs.dirname(git) or vim.fn.getcwd()
    end,

    should_attach = function(buf_id, _)
      if not vim.bo[buf_id].buflisted then
        return false
      end
      if vim.bo[buf_id].buftype ~= "" then
        return false
      end
      return true
    end,

    server = {
      type = "nodejs",
      custom_server_filepath = nil,
    },

    server_opts_overrides = {},
  })
end

-- }}}
-- mcphub {{{
local mcphub = req("mcphub")
if mcphub then
  mcphub.setup({
    -- keep this simple at first
    auto_approve = false,
  })

  vim.api.nvim_create_user_command("MCP", function()
    vim.cmd("MCPHub")
  end, {})
end
-- }}}
-- codecompanion {{{

local codecompanion = req("codecompanion")
if codecompanion then
  local extensions = {}

  if mcphub ~= nil then
    extensions.mcphub = {
      callback = "mcphub.extensions.codecompanion",
      opts = {
        make_tools = true,
        show_server_tools_in_chat = true,
        add_mcp_prefix_to_tool_names = false,
        show_result_in_chat = true,
        format_tool = nil,
        make_vars = true,
        make_slash_commands = true,
      },
    }
  end

  codecompanion.setup({
    extensions = extensions,

    interactions = {
      chat = { adapter = "copilot", variables = {} },
      inline = { adapter = "copilot" },

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

    tools = {
      default_tools = { "agent" },
    },

    display = {
      action_palette = { provider = "default" },
    },

    opts = {
      log_level = "debug",
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

-- }}}
-- blink.cmp {{{

if blink then
  blink.setup({
    sources = {
      default = { "lsp", "path", "snippets", "buffer", "copilot" },
      providers = {
        copilot = {
          name = "copilot",
          module = "blink-cmp-copilot",
          score_offset = 100,
          async = true,
        },
      },
    },

    fuzzy = {
      implementation = "lua",
    },

    completion = {
      ghost_text = { enabled = true },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
        update_delay_ms = 50,
        treesitter_highlighting = true,
        window = {
          border = "rounded",
          winblend = 12,
          scrollbar = true,
          max_width = 90,
          max_height = 20,
        },
      },
      menu = {
        border = "rounded",
        winblend = 12,
        draw = {
          columns = {
            { "label", "label_description", gap = 1 },
            { "kind" },
          },
        },
      },
    },

    signature = {
      enabled = true,
      window = {
        border = "rounded",
        winblend = 12,
        show_documentation = true,
      },
    },
  })
end

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
