if vim.b.current_syntax ~= "markdown" then return end

vim.api.nvim_set_hl(0, "markdownH2", { link = "Type" })
vim.api.nvim_set_hl(0, "markdownH3", { link = "Underlined" })
vim.api.nvim_set_hl(0, "markdownH4", { link = "Identifier" })
vim.api.nvim_set_hl(0, "markdownH5", { link = "Statement" })
vim.api.nvim_set_hl(0, "markdownH6", { link = "Constant" })
