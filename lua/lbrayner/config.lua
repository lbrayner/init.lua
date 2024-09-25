-- fidget.nvim

-- Standalone UI for nvim-lsp progress. Eye candy for the impatient.
-- Installed as a dependency of rocks.nvim
require("fidget").setup({
  notification = {
    window = {
      winblend = 0, -- to fix the interaction with transparent backgrounds
    },
  },
})

-- Improved alternate file mapping
vim.keymap.set("n", "<Space>a", function()
  local alternate = vim.fn.bufnr("#")
  if alternate > 0 and vim.api.nvim_buf_is_valid(alternate) then
    local name = vim.fn.pathshorten(require("lbrayner.path").full_path())
    vim.api.nvim_set_current_buf(alternate)
    require("lbrayner.flash").flash_window()
    require("fidget").notify(string.format("Switched to alternate buffer. Previous buffer was %s.", name))
  else
    vim.notify("Alternate buffer is not valid.")
  end
end)

-- fzf-lua

if pcall(require, "fzf-lua") then
  require("lbrayner.config.fzf-lua")
end

-- lir.nvim

if pcall(require, "lir") then
  require("lbrayner.config.lir")
end

-- mini.nvim

if pcall(require, "mini.align") then
  require("lbrayner.config.mini")
end

-- neosolarized.nvim

if pcall(require, "neosolarized") then
  require("lbrayner.config.neosolarized")
end

-- nvim-colorizer.lua

if pcall(require, "colorizer") then
  require("colorizer").setup()
end

-- nvim-dap-ui

if pcall(require, "dapui") then
  require("lbrayner.config.dap")
end

-- nvim-lspconfig

if pcall(require, "lspconfig") then
  require("lbrayner.config.lsp")
end

-- nvim-jdtls: skipping autocmds and commands
vim.g.nvim_jdtls = 1

-- nvim-snippy

if pcall(require, "snippy.mapping") then
  require("lbrayner.config.lsp-completion")
end

-- nvim-spider

vim.keymap.set({"n", "o", "x"}, "<Leader>w", "<cmd>lua require('spider').motion('w')<CR>", { desc = "Spider-w" })
vim.keymap.set({"n", "o", "x"}, "<Leader>e", "<cmd>lua require('spider').motion('e')<CR>", { desc = "Spider-e" })
vim.keymap.set({"n", "o", "x"}, "<Leader>b", "<cmd>lua require('spider').motion('b')<CR>", { desc = "Spider-b" })
vim.keymap.set({"n", "o", "x"}, "<Leader>ge", "<cmd>lua require('spider').motion('ge')<CR>", {
  desc = "Spider-ge" })

-- tint.nvim

if pcall(require, "tint") then
  require("lbrayner.config.tint")
end

-- typescript-tools.nvim

if pcall(require, "typescript-tools") then
  require("typescript-tools").setup({
    autostart = false,
    capabilities = require("lbrayner.lsp").default_capabilities(),
  })
end