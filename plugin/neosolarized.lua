require("neosolarized").setup({
  background_set = false,
  comment_italics = false,
})

local neosolarized = vim.api.nvim_create_augroup("neosolarized", { clear = true })

vim.api.nvim_create_autocmd("ColorScheme", {
  group = neosolarized,
  pattern = "neosolarized",
  callback = function()
    vim.cmd("hi QuickFixLine guibg=#002b36 guifg=#6c71c4 gui=NONE")
    vim.cmd("hi! link NormalNC Normal")
    vim.wo.cursorline = true
  end,
})

vim.cmd("colorscheme neosolarized")
