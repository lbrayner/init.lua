-- Subsection: options {{{

vim.o.backspace =  "indent,eol,start"
vim.o.backupcopy = "yes"
vim.o.breakindent = true
vim.o.clipboard = "unnamed,unnamedplus"
vim.o.completeopt = "menuone,popup"
vim.o.cursorline = true
vim.o.expandtab = true
vim.o.fileformat = "unix"
vim.o.fileformats = "unix,dos"
vim.o.ignorecase = true
vim.o.lazyredraw = true
vim.o.linebreak = true
vim.o.listchars = "eol:¬,tab:» ,trail:·"
vim.o.number = true
vim.o.relativenumber = true
vim.o.ruler = false
vim.o.shiftwidth = 2
vim.o.showmode = false
vim.o.smartcase = true
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.switchbuf = "usetab,uselast"
vim.o.synmaxcol = 500 -- From tpope's vim-sensible (lowering this improves performance in files with long lines)
vim.o.tabstop = 2
vim.o.termguicolors = true
vim.o.title = true
vim.o.wildmenu = true
vim.o.wildmode = "longest:full"

-- }}}

-- Variables

-- remapping leader to comma
vim.g.mapleader = ","
-- See $VIMRUNTIME/ftplugin/markdown.vim
vim.g.markdown_recommended_style = 0

-- Subsection: mappings — pt-BR keyboard {{{

-- disable Ex mode mapping
vim.keymap.set("n", "Q", "<Nop>", { remap = true })

-- cedilla is right where : is on an en-US keyboard
vim.keymap.set("n", "ç", ":")
vim.keymap.set("v", "ç", ":")
vim.keymap.set("n", "Ç", ":<Up><CR>")
vim.keymap.set("v", "Ç", ":<Up><CR>")
vim.keymap.set("n", "¬", "^")
vim.keymap.set("n", "qç", "q:")
vim.keymap.set("v", "qç", "q:")
vim.keymap.set("v", "¬", "^")

-- alternate file
vim.keymap.set("n", "<Space>a", "<Cmd>b#<CR>")

-- clear search highlights
vim.keymap.set("n", "<F2>", "<Cmd>set invhlsearch hlsearch?<CR>", { silent = true })

-- easier window switching
vim.keymap.set("n", "<C-H>", "<Cmd>wincmd h<CR>")
vim.keymap.set("n", "<C-J>", "<Cmd>wincmd j<CR>")
vim.keymap.set("n", "<C-K>", "<Cmd>wincmd k<CR>")
vim.keymap.set("n", "<C-L>", "<Cmd>wincmd l<CR>")

-- write
vim.keymap.set({ "n", "v" }, "<F6>", "<Cmd>w<CR>")
vim.keymap.set("i", "<F6>", "<Esc><Cmd>w<CR>")

-- list mode
vim.keymap.set({
  "", -- nvo: normal, visual, operator-pending
  "i" }, "<F12>", "<Cmd>set list!<CR>", { silent = true })

-- quickfix and locallist
vim.keymap.set("n", "<Space>l", "<Cmd>lopen<CR>", { silent = true })
vim.keymap.set("n", "<Space>q", "<Cmd>botright copen<CR>", { silent = true })

-- Close preview window
vim.keymap.set("n", "<Space>p", "<Cmd>pclose<CR>", { silent = true })

-- force case sensitivity for *-search
vim.keymap.set("n", "*", [[/\C\V\<<C-R><C-W>\><CR>]])

-- Neovim terminal
-- Case matters for keys after alt or meta
vim.keymap.set("t", "<A-h>", [[<C-\><C-N><C-W>h]])
vim.keymap.set("t", "<A-j>", [[<C-\><C-N><C-W>j]])
vim.keymap.set("t", "<A-k>", [[<C-\><C-N><C-W>k]])
vim.keymap.set("t", "<A-l>", [[<C-\><C-N><C-W>l]])

-- Command line

-- Emacs-style editing in command-line mode and insert mode
-- Case matters for keys after alt or meta

-- Return to Normal mode
vim.keymap.set("c", "<C-G>", "<C-C>")

-- kill line
vim.keymap.set("c", "<C-K>", "<C-F>D<C-C><Right>")
vim.keymap.set("i", "<C-K>", "<C-O>D")

-- Insert digraph
vim.keymap.set({ "c", "i" }, "<C-X>8", "<C-K>")

-- inserting the current line
vim.keymap.set("c", "<C-R><C-L>", [[<C-R>=getline(".")<CR>]])
-- inserting the current line number
vim.keymap.set("c", "<C-R><C-N>", [[<C-R>=line(".")<CR>]])

-- Insert timestamps
vim.keymap.set("i", "<F3>", [[<C-R>=strftime("%Y-%m-%d %a %0H:%M")<CR>]])

-- Rename word
vim.keymap.set("n", "<Leader>a", [[:keepp %s/\C\V\<<C-R><C-W>\>//gc<Left><Left><Left>]])
vim.keymap.set("n", "<Leader>x", [[:keepp .,$s/\C\V\<<C-R><C-W>\>//gc<Left><Left><Left>]])
-- Rename visual selection
vim.keymap.set("v", "<Leader>a", [[""y:keepp %s/\C\V<C-R>"//gc<Left><Left><Left>]])
vim.keymap.set("v", "<Leader>x", [[""y:keepp .,$s/\C\V<C-R>"//gc<Left><Left><Left>]])

-- From vim-unimpaired: insert blank lines above and below
vim.keymap.set("n", "[<Space>", [[<Cmd>exe "put!=repeat(nr2char(10), v:count1)\<Bar>silent ']+"<CR>]])
vim.keymap.set("n", "]<Space>", [[<Cmd>exe "put =repeat(nr2char(10), v:count1)\<Bar>silent ']-"<CR>]])

-- }}}

-- Modules

require("lbrayner.autocmds")
require("lbrayner.buffer")
require("lbrayner.clipboard")
require("lbrayner.coerce")
require("lbrayner.diagnostic")
require("lbrayner.diff")
require("lbrayner.flash")
require("lbrayner.highlight")
require("lbrayner.marks")
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
