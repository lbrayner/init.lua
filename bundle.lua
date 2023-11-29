local config = vim.fs.normalize(vim.fn.fnamemodify(vim.fn.stdpath("config"), ":p")) -- ~/.config/nvim
local data = vim.fs.normalize(vim.fn.fnamemodify(vim.fn.stdpath("data"), ":p")) -- ~/.local/share/nvim

vim.opt.runtimepath:remove(config)
vim.opt.runtimepath:remove(vim.fs.joinpath(config, "after"))
vim.opt.runtimepath:remove(vim.fs.joinpath(data, "site"))
vim.opt.runtimepath:remove(vim.fs.joinpath(data, "site/after"))

vim.opt.packpath:remove(config)
vim.opt.packpath:remove(vim.fs.joinpath(config, "after"))
vim.opt.packpath:remove(vim.fs.joinpath(data, "site"))
vim.opt.packpath:remove(vim.fs.joinpath(data, "site/after"))

local vim_dir = vim.fn.expand("<sfile>:p:h")

vim.opt.runtimepath:append(vim_dir)
vim.opt.runtimepath:append(vim.fs.joinpath(vim_dir, "after"))
vim.opt.packpath:append(vim_dir)
vim.opt.packpath:append(vim.fs.joinpath(vim_dir, "after"))

-- sourcing init.lua

local init = vim.fs.joinpath(vim_dir, "init.lua")
if vim.fn.filereadable(init) then
  vim.cmd.source(vim.fn.fnameescape(init))
end
