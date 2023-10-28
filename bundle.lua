local config = vim.fn.fnamemodify(vim.fn.stdpath("config"), ":h:p")
local data = vim.fn.fnamemodify(vim.fn.stdpath("data"), ":h:p")

local _config_ = vim.fn.fnameescape(config)
local _data_ = vim.fn.fnameescape(data)

vim.cmd(string.format("set runtimepath-=%s/nvim", _config_))
vim.cmd(string.format("set runtimepath-=%s/nvim/after", _config_))
vim.cmd(string.format("set runtimepath-=%s/nvim/site", _data_))
vim.cmd(string.format("set runtimepath-=%s/nvim/site/after", _data_))

vim.cmd(string.format("set packpath-=%s/nvim", _config_))
vim.cmd(string.format("set packpath-=%s/nvim/after", _config_))
vim.cmd(string.format("set packpath-=%s/nvim/site", _data_))
vim.cmd(string.format("set packpath-=%s/nvim/site/after", _data_))

local vim_dir = vim.fn.expand("<sfile>:p:h")
local _vim_dir_ = vim.fn.fnameescape(vim_dir)

vim.cmd(string.format("set runtimepath+=%s", _vim_dir_))
vim.cmd(string.format("set runtimepath+=%s/after", _vim_dir_))
vim.cmd(string.format("set packpath+=%s", _vim_dir_))
vim.cmd(string.format("set packpath+=%s/after", _vim_dir_))

-- sourcing init.lua

local init = vim_dir.."/init.lua"
if vim.fn.filereadable(init) then
  vim.cmd.source(vim.fn.fnameescape(init))
end
