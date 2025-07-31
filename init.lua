-- Set up rocks.nvim

local rocks_config = vim.g.rocks_nvim or { -- g:rocks_nvim may have been set in bundle.lua
  rocks_path = vim.fs.normalize("~/.local/share/nvim/rocks"),
}

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

-- Variables

-- remapping leader to comma
vim.g.mapleader = ","
-- See $VIMRUNTIME/ftplugin/markdown.vim
vim.g.markdown_recommended_style = 0

-- Modules

require("lbrayner.autocmds")
require("lbrayner.clipboard")
require("lbrayner.clojure")
require("lbrayner.coerce")
require("lbrayner.diagnostic")
require("lbrayner.diff")
require("lbrayner.highlight")
require("lbrayner.lsp")
require("lbrayner.mappings")
require("lbrayner.marks")
require("lbrayner.options")
require("lbrayner.ripgrep")
require("lbrayner.statusline")
require("lbrayner.tab")
require("lbrayner.tabline")
require("lbrayner.user_commands")
require("lbrayner.vim_plugins")
require("lbrayner.wipe")

-- Source init files

local vim_dir = vim.fn.expand("<sfile>:p:h")

local files = {
  vim.fs.joinpath(vim_dir, "local.lua"),
}

vim.iter(files):filter(
  function(f)
    return vim.uv.fs_stat(f)
  end
):each(
  function(f)
    vim.cmd.source(f)
  end
)

-- Configure Neovim Lua plugins

require("lbrayner.setup")
