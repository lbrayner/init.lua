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

local vim_dir = vim.fn.expand("<sfile>:p:h")

vim.opt.runtimepath:append(vim_dir)
vim.opt.runtimepath:append(vim.fs.joinpath(vim_dir, "after"))
vim.opt.packpath:append(vim_dir)
vim.opt.packpath:append(vim.fs.joinpath(vim_dir, "after"))

-- Sourcing init files

local files = {
  vim.fs.joinpath(vim_dir, "init.lua"),
}

for _, init in ipairs(files) do
  if vim.fn.filereadable(init) == 1 then
    vim.cmd.source(init)
  end
end
