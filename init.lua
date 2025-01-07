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
require("lbrayner.quickfix")
require("lbrayner.ripgrep")
require("lbrayner.statusline")
require("lbrayner.tab")
require("lbrayner.tabline")
require("lbrayner.terminal")
require("lbrayner.user_commands")
require("lbrayner.wipe")

-- Sourcing init files

local vim_dir = vim.fn.expand("<sfile>:p:h")

local files = {
  vim.fs.joinpath(vim_dir, "local.lua"),
}

for _, init in ipairs(files) do
  if vim.fn.filereadable(init) == 1 then
    vim.cmd.source(init)
  end
end

-- Subsection: rocks.nvim {{{

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

-- }}}

-- Neovim Lua plugins

require("lbrayner.config")

-- Subsection: Vim plugins {{{

-- reply.vim
vim.api.nvim_create_user_command("ReplFile", [[call reply#command#send(join(getline(1,line("$")),"\n"),0,0)]], {
  nargs = 0 })

-- vim-characterize

vim.keymap.set("n", "<F13>", "<Plug>(characterize)", { remap = true })
vim.api.nvim_create_user_command("Characterize", [[exe "normal \<F13>"]], { nargs = 0 })

-- vim-dadbod
require("lbrayner.database")

-- vim-fugitive

local fugitive_setup = vim.api.nvim_create_augroup("fugitive_setup", { clear = true })

vim.api.nvim_create_autocmd("SourcePost", {
  pattern = "*/plugin/fugitive.vim",
  group = fugitive_setup,
  desc = "Fugitive setup",
  callback = function()
    require("lbrayner.fugitive").setup()
  end,
})

-- vim-quickhl

vim.keymap.set("n", "<Space>m", "<Plug>(quickhl-manual-this)", { remap = true })
vim.keymap.set("x", "<Space>m", "<Plug>(quickhl-manual-this)", { remap = true })
vim.keymap.set("n", "<Space>M", "<Plug>(quickhl-manual-reset)", { remap = true })
vim.keymap.set("x", "<Space>M", "<Plug>(quickhl-manual-reset)", { remap = true })

vim.keymap.set("n", "<Space>w", "<Plug>(quickhl-manual-this-whole-word)", { remap = true })
vim.keymap.set("x", "<Space>w", "<Plug>(quickhl-manual-this-whole-word)", { remap = true })

vim.keymap.set("n", "<Space>c", "<Plug>(quickhl-manual-clear)", { remap = true })
vim.keymap.set("v", "<Space>c", "<Plug>(quickhl-manual-clear)", { remap = true })

-- vim-rsi

-- vim-rsi's M-d is not at parity with readline's M-d
-- Case matters for keys after alt or meta

local vim_rsi_override = vim.api.nvim_create_augroup("vim_rsi_override", { clear = true })

vim.api.nvim_create_autocmd("VimEnter", {
  group = vim_rsi_override,
  desc = "Override vim-rsi mappings",
  callback = function()
    vim.keymap.set("c", "<M-d>", "<C-F>ea<C-W><C-C>")
  end,
})

if vim.v.vim_did_enter == 1 then
  vim.api.nvim_exec_autocmds("VimEnter", { group = vim_rsi_override })
end

-- vim-rzip
vim.g.rzipPlugin_extra_ext = "*.odt"

-- }}}

-- vim: fdm=marker
