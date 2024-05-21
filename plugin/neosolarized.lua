vim.g.default_colorscheme = "neosolarized"

local neosolarized = vim.api.nvim_create_augroup("neosolarized", { clear = true })

vim.api.nvim_create_autocmd("ColorScheme", {
  group = neosolarized,
  pattern = "neosolarized",
  callback = function()
    vim.cmd("hi QuickFixLine guibg=#002b36 guifg=#6c71c4 gui=NONE")
    vim.cmd("hi! link NormalNC Normal")
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  group = neosolarized,
  desc = "Set colorscheme to neosolarized by default",
  callback = function()
    if vim.g.default_colorscheme == "neosolarized" then
      vim.schedule(function()
        require("neosolarized").setup({
          background_set = false,
          comment_italics = false,
        })

        vim.cmd("doautocmd ColorScheme neosolarized")
      end)
    end
  end,
})
