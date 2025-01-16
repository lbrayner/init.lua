if vim.b.current_syntax ~= "fugitive" then return end

vim.api.nvim_set_hl(0, "fugitiveUntrackedHeading", { link = "Comment" })
vim.api.nvim_set_hl(0, "fugitiveStagedHeading", { link = "Underlined" })
