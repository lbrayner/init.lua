local bundle = vim.fn.expand("<sfile>:p:h")

-- Set up rocks.nvim

vim.g.rocks_nvim = {
  rocks_path = vim.fs.joinpath(bundle, ".rocks"),
}

-- TODO till rocks-git.nvim install path is configurable

-- Bundle paths

local config = vim.fn.stdpath("config") -- ~/.config/nvim
local data = vim.fn.stdpath("data") -- ~/.local/share/nvim

vim.opt.runtimepath:remove(config)
vim.opt.runtimepath:remove(vim.fs.joinpath(config, "after"))
vim.opt.runtimepath:remove(vim.fs.joinpath(data, "site"))
vim.opt.runtimepath:remove(vim.fs.joinpath(data, "site", "after"))

vim.opt.packpath:remove(config)
vim.opt.packpath:remove(vim.fs.joinpath(config, "after"))
vim.opt.packpath:remove(vim.fs.joinpath(data, "site"))
vim.opt.packpath:remove(vim.fs.joinpath(data, "site", "after"))

vim.opt.runtimepath:append(bundle)
vim.opt.runtimepath:append(vim.fs.joinpath(bundle, "after"))
vim.opt.packpath:append(bundle)
vim.opt.packpath:append(vim.fs.joinpath(bundle, "after"))

-- Source init files

local files = {
  vim.fs.joinpath(bundle, "init.lua"),
}

for _, init in ipairs(files) do
  if vim.uv.fs_stat(init) then
    vim.cmd.source(init)
  end
end
