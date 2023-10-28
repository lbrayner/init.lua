local config = vim.fn.fnamemodify(vim.fn.stdpath("config"), ":h:p")
local data = vim.fn.fnamemodify(vim.fn.stdpath("data"), ":h:p")

vim.opt.runtimepath:remove(string.format("%s/nvim", config))
vim.opt.runtimepath:remove(string.format("%s/nvim/after", config))
vim.opt.runtimepath:remove(string.format("%s/nvim/site", data))
vim.opt.runtimepath:remove(string.format("%s/nvim/site/after", data))

vim.opt.packpath:remove(string.format("%s/nvim", config))
vim.opt.packpath:remove(string.format("%s/nvim/after", config))
vim.opt.packpath:remove(string.format("%s/nvim/site", data))
vim.opt.packpath:remove(string.format("%s/nvim/site/after", data))

local vim_dir = vim.fn.expand("<sfile>:p:h")

vim.opt.runtimepath:append(string.format("%s", vim_dir))
vim.opt.runtimepath:append(string.format("%s/after", vim_dir))
vim.opt.packpath:append(string.format("%s", vim_dir))
vim.opt.packpath:append(string.format("%s/after", vim_dir))

-- sourcing init.lua

local init = vim_dir.."/init.lua"
if vim.fn.filereadable(init) then
  vim.cmd.source(vim.fn.fnameescape(init))
end
