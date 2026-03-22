vim.lsp.enable("tsserver")
vim.lsp.config('tsserver', {
  cmd = {'typescript-language-server', '--stdio'},
  filetypes = { 'typescript', 'javascript', 'typescriptreact', 'javascriptreact' },
  root_dir = vim.fs.root(0, {'package.json', '.git'}),
  on_attach = on_attach,
  capabilities = capabilities,
})

vim.o.autoread = true

vim.g.opencode_opts = {
  lsp = {
    enabled = false,
  },
}

local op = require("opencode")

require("snacks").setup({
  input = {},
  picker = {
    actions = {
      opencode_send = function(...)
        return op.snacks_picker_send(...)
      end,
    },
    win = {
      input = {
        keys = {
          ["<A-a>"] = { "opencode_send", mode = { "n", "i" } },
        },
      },
    },
  },
})

vim.keymap.set({ "n", "x" }, "<leader>oa", function()
  op.ask("@this: ", { submit = true })
end, { desc = "Ask opencode" })

vim.keymap.set("n", "<leader>oo", function()
  op.select()
end, { desc = "Opencode actions" })

vim.keymap.set({ "n", "t" }, "<leader>ot", function()
  op.toggle()
end, { desc = "Toggle opencode" })

vim.keymap.set({ "n", "x" }, "<leader>oe", function()
  op.prompt("explain")
end, { desc = "Explain selection" })

vim.keymap.set({ "n", "x" }, "<leader>or", function()
  op.prompt("review")
end, { desc = "Review selection" })

vim.keymap.set("n", "<leader>of", function()
  op.prompt("fix")
end, { desc = "Fix diagnostics" })

vim.keymap.set("n", "<leader>og", function()
  op.prompt("diff")
end, { desc = "Review git diff" })

vim.keymap.set({ "n", "x" }, "go", function()
  return op.operator("@this ")
end, { expr = true, desc = "Add range to opencode" })

vim.keymap.set("n", "goo", function()
  return op.operator("@this ") .. "_"
end, { expr = true, desc = "Add line to opencode" })

vim.keymap.set("n", "<leader>on", function()
  op.command("session.new")
end, { desc = "New opencode session" })

vim.keymap.set("n", "<leader>os", function()
  op.command("session.select")
end, { desc = "Select opencode session" })

vim.cmd.cd("~/portal")

vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.expandtab = true
vim.opt.smarttab = true
vim.opt.breakindent = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2

-- require("tokyonight").setup {
--     transparent = true,
--     styles = {
--        sidebars = "transparent",
--        floats = "transparent",
--     }
-- }
--
-- vim.cmd.colorscheme("tokyonight")

-- vim.cmd [[
--   highlight Normal guibg=none
--   highlight NonText guibg=none
--   highlight Normal ctermbg=none
--   highlight NonText ctermbg=none
-- ]]

require("tokyonight").setup({
  transparent = true,
  styles = {
    sidebars = "transparent",
    floats = "dark",
  },
})

vim.cmd.colorscheme("tokyonight")

vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NonText", { bg = "none" })

vim.opt.winblend = 12
vim.opt.pumblend = 12

-- local telescope = require("telescope")
-- local builtin = require("telescope.builtin")

-- telescope.setup({
--   defaults = {
--     path_display = { "smart" },
--   },
--   pickers = {
--     find_files = {
--       hidden = true,
--     },
--     live_grep = {
--       additional_args = function()
--         return { "--hidden", "--glob", "!.git/*" }
--       end,
--     },
--   },
-- })
--
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
