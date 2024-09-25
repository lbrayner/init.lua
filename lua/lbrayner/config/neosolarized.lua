local neosolarized = vim.api.nvim_create_augroup("neosolarized", { clear = true })

vim.api.nvim_create_autocmd("ColorScheme", {
  group = neosolarized,
  pattern = "neosolarized",
  callback = function()
    vim.api.nvim_set_hl(0, "NormalNC", { force = true, link = "Normal" })
    vim.api.nvim_set_hl(0, "QuickFixLine", { bg = "#002b36", fg = "#6c71c4" })
  end,
})

if vim.fn.has("gui_running") == 0 then
  require("neosolarized").setup({
    background_set = false,
    comment_italics = false,
  })

  vim.cmd.colorscheme("neosolarized")
end
