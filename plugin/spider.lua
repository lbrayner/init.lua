-- TODO move to init.lua

vim.keymap.set({"n", "o", "x"}, "<Leader>w", "<cmd>lua require('spider').motion('w')<CR>", { desc = "Spider-w" })
vim.keymap.set({"n", "o", "x"}, "<Leader>e", "<cmd>lua require('spider').motion('e')<CR>", { desc = "Spider-e" })
vim.keymap.set({"n", "o", "x"}, "<Leader>b", "<cmd>lua require('spider').motion('b')<CR>", { desc = "Spider-b" })
vim.keymap.set({"n", "o", "x"}, "<Leader>ge", "<cmd>lua require('spider').motion('ge')<CR>", {
  desc = "Spider-ge" })
