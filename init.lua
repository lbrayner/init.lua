-- Variables

-- remapping leader to comma
vim.g.mapleader = ","
-- See $VIMRUNTIME/ftplugin/markdown.vim
vim.g.markdown_recommended_style = 0

-- Modules

require("lbrayner.autocmds")
require("lbrayner.buffer")
require("lbrayner.clipboard")
require("lbrayner.coerce")
require("lbrayner.diagnostic")
require("lbrayner.diff")
require("lbrayner.flash")
require("lbrayner.highlight")
require("lbrayner.mappings")
require("lbrayner.marks")
require("lbrayner.options")
require("lbrayner.ripgrep")
require("lbrayner.statusline")
require("lbrayner.tab")
require("lbrayner.tabline")
require("lbrayner.terminal")
require("lbrayner.user_commands")
require("lbrayner.vim_plugins")
require("lbrayner.wipe")

-- Source init files

local vim_dir = vim.fn.expand("<sfile>:p:h")

local files = {
  vim.fs.joinpath(vim_dir, "local.lua"),
}

for _, init in ipairs(files) do
  if vim.fn.filereadable(init) == 1 then
    vim.cmd.source(init)
  end
end

-- Set up rocks.nvim

local rocks_config = {
  rocks_path = vim.fs.normalize("~/.local/share/nvim/rocks"),
}

-- rocks.nvim wasn't synced at least once
if not vim.uv.fs_stat(vim.fs.normalize("~/.local/share/nvim/site/pack/rocks/start/neosolarized.nvim")) then
  -- A statusline theme is required
  require("lbrayner.statusline").load_theme("neosolarized")
end

vim.g.rocks_nvim = rocks_config

local luarocks_path = {
  vim.fs.joinpath(rocks_config.rocks_path, "share", "lua", "5.1", "?.lua"),
  vim.fs.joinpath(rocks_config.rocks_path, "share", "lua", "5.1", "?", "init.lua"),
}

package.path = package.path .. ";" .. table.concat(luarocks_path, ";")

local luarocks_cpath = {
  vim.fs.joinpath(rocks_config.rocks_path, "lib", "lua", "5.1", "?.so"),
  vim.fs.joinpath(rocks_config.rocks_path, "lib64", "lua", "5.1", "?.so"),
}

package.cpath = package.cpath .. ";" .. table.concat(luarocks_cpath, ";")

local rocks_rtp = {
  rocks_config.rocks_path,
  "lib",
  "luarocks",
  "rocks-5.1",
  "rocks.nvim",
  "*"
}

vim.opt.runtimepath:append(vim.fs.joinpath(unpack(rocks_rtp)))

-- Configure Neovim Lua plugins

require("lbrayner.config")
