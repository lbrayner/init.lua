vim.g.default_colorscheme = "neosolarized"

local neosolarized = vim.api.nvim_create_augroup("neosolarized", { clear = true })

vim.api.nvim_create_autocmd("ColorScheme", {
  group = neosolarized,
  pattern = "neosolarized",
  callback = function()
    vim.api.nvim_set_hl(0, "NormalNC", { force = true, link = "Normal" })
    vim.api.nvim_set_hl(0, "QuickFixLine", { bg = "#002b36", fg = "#6c71c4" })
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

        vim.cmd.colorscheme("neosolarized")
      end)
    end
  end,
})
