-- Subsection: settings {{{

vim.bo.expandtab = true
vim.bo.fileformat = "unix"
vim.bo.shiftwidth = 2 -- when indenting with '>', use 2 spaces width
vim.bo.synmaxcol = 500 -- From tpope's vim-sensible (lowering this improves performance in files with long lines)
vim.bo.tabstop = 4 -- show existing tab with 4 spaces width

vim.go.backspace =  "indent,eol,start"
vim.go.backupcopy = "yes" -- So that watchprocesses work as expected
vim.go.completeopt = "menuone"
vim.go.fileformats = "unix,dos"
vim.go.ignorecase = true
vim.go.lazyredraw = true
vim.go.listchars = "eol:¬,tab:» ,trail:·"
vim.go.ruler = false
vim.go.showmode = false
vim.go.smartcase = true
vim.go.splitbelow = true
vim.go.splitright = true
vim.go.switchbuf = "usetab,uselast"
if vim.env.TERM == "foot" or string.find(vim.env.TERM, "256color") then
    vim.go.termguicolors = true
end
vim.go.title = true
vim.go.wildmenu = true
vim.go.wildmode = "longest:full"

vim.wo.breakindent = true
vim.wo.cursorline = true
vim.wo.linebreak = true
vim.wo.number = true
vim.wo.relativenumber = true
-- }}}

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

-- make the current window the only one on the screen
vim.keymap.set("n", "<Space>o", "<Cmd>only<CR>")
-- alternate file
vim.keymap.set("n", "<Space>a", "<Cmd>b#<CR>")

-- clear search highlights
vim.keymap.set("n", "<F2>", "<Cmd>set invhlsearch hlsearch?<CR>", { silent = true })

-- easier window switching
vim.keymap.set("n", "<C-H>", "<C-W>h")
vim.keymap.set("n", "<C-J>", "<C-W>j")
vim.keymap.set("n", "<C-K>", "<C-W>k")
vim.keymap.set("n", "<C-L>", "<C-W>l")

vim.keymap.set("v", "<C-H>", "<Esc><C-W>h")
vim.keymap.set("v", "<C-J>", "<Esc><C-W>j")
vim.keymap.set("v", "<C-K>", "<Esc><C-W>k")
vim.keymap.set("v", "<C-L>", "<Esc><C-W>l")

-- splits
vim.keymap.set("n", "<Leader>v", "<C-W>v")
vim.keymap.set("n", "<Leader>h", "<C-W>s")

-- write
vim.keymap.set("n", "<F6>", "<Cmd>w<CR>")
vim.keymap.set("i", "<F6>", "<Esc><Cmd>w<CR>")
vim.keymap.set("v", "<F6>", "<Esc><Cmd>w<CR>")
vim.keymap.set("n", "<Leader><F6>", "<Cmd>w!<CR>")

-- list mode
vim.keymap.set("n", "<F12>", "<Cmd>setlocal list!<CR>", { silent = true })
vim.keymap.set("i", "<F12>", "<Cmd>setlocal list!<CR>", { silent = true })

-- quickfix and locallist
vim.keymap.set("n", "<Space>l", "<Cmd>lopen<CR>", { silent = true })
vim.keymap.set("n", "<Space>q", "<Cmd>botright copen<CR>", { silent = true })

-- force case sensitivity for *-search
vim.keymap.set("n", "*", [[/\C\V\<<C-R><C-W>\><CR>]])

-- Neovim terminal
-- Case matters for keys after alt or meta
vim.keymap.set("t", "<A-h>", [[<C-\><C-N><C-W>h]])
vim.keymap.set("t", "<A-j>", [[<C-\><C-N><C-W>j]])
vim.keymap.set("t", "<A-k>", [[<C-\><C-N><C-W>k]])
vim.keymap.set("t", "<A-l>", [[<C-\><C-N><C-W>l]])

-- Search selected file path: based on Nvim builtin vmap *
vim.keymap.set("v", "<Leader>8", [[y/\V<C-R>=escape("<C-R>"", "/")<CR><CR>]])

-- Command line

-- Emacs-style editing in command-line mode and insert mode
-- Case matters for keys after alt or meta

-- Return to Normal mode
vim.keymap.set("c", "<C-G>", "<C-C>")

-- kill line
vim.keymap.set("c", "<C-K>", "<C-F>D<C-C><Right>")
vim.keymap.set("i", "<C-K>", "<C-O>D")

-- Insert digraph
vim.keymap.set("c", "<C-X>8", "<C-K>")
vim.keymap.set("i", "<C-X>8", "<C-K>")

-- inserting the current line
vim.keymap.set("c", "<C-R><C-L>", [[<C-R>=getline(".")<CR>]])
-- inserting the current line number
vim.keymap.set("c", "<C-R><C-N>", [[<C-R>=line(".")<CR>]])

-- Insert timestamps
vim.keymap.set("i", "<F3>", [[<C-R>=strftime("%Y-%m-%d %a %0H:%M")<CR>]])

-- Rename word
vim.keymap.set("n", "<Leader>x", [[:%s/\C\V\<<C-R><C-W>\>//gc<Left><Left><Left>]])
-- Rename visual selection
vim.keymap.set("v", "<Leader>x", [[y:%s/\C\V<C-R>"//gc<Left><Left><Left>]])

-- Go to next file mark
vim.keymap.set("n", "[4", require("lbrayner.marks").go_to_next_file_mark)
vim.keymap.set("n", "]4", require("lbrayner.marks").go_to_previous_file_mark)

-- From vim-unimpaired: insert blank lines above and below
vim.keymap.set("n", "[<Space>", [[<Cmd>exe "put!=repeat(nr2char(10), v:count1)\<Bar>silent ']+"<CR>]])
vim.keymap.set("n", "]<Space>", [[<Cmd>exe "put =repeat(nr2char(10), v:count1)\<Bar>silent ']-"<CR>]])

-- }}}

-- Subsection: functions & commands {{{

vim.api.nvim_create_user_command("DeleteTrailingWhitespace", function(command)
  require("lbrayner").preserve_view_port(function()
    vim.cmd(string.format([[keeppatterns %s,%ss/\s\+$//e]], command.line1, command.line2))
  end)
end, { bar = true, nargs = 0, range = "%" })

-- }}}

-- Ripgrep

vim.go.grepprg = "rg --vimgrep"
vim.go.grepformat = "%f:%l:%c:%m"
vim.go.shellpipe = "&>"

local function rg(txt)
  local ripgrep = require("lbrayner.ripgrep")
  local success, err = pcall(ripgrep.rg, txt)

  if not success then
    vim.cmd.cclose()
    if type(err) == "string" and vim.startswith(err, "Rg") then
      vim.cmd.echoerr(string.format("'%s'", err))
      return
    end
    vim.cmd.echomsg(string.format("'Error searching for %s. Unmatched quotes? Check your command.'", txt))
    return
  end

  if not vim.tbl_isempty(vim.fn.getqflist()) then
    vim.cmd("botright copen")
  else
    vim.cmd.cclose()
    vim.cmd.echomsg(string.format("'No match found for %s.'", txt))
  end
end

vim.api.nvim_create_user_command("Rg", function(command)
  rg(command.args)
end, { nargs = "*" })

vim.keymap.set("ca", "Rg", "Rg -e")
vim.keymap.set("ca", "Rb", [[Rg -s -e'\b''''\b'<Left><Left><Left><Left><Left>]])
vim.keymap.set("ca", "Rw", [[Rg -s -e'\b''<C-R><C-W>''\b']])

local vim_dir = vim.fn.stdpath("config")

if vim.env.MYVIMRC == "" then
  vim_dir = vim.fn.expand("<sfile>:p:h")
end

-- Finish here if we haven't initialized the submodules

if vim.fn.glob(vim_dir.."/pack/bundle/start/*/plugin") == "" then
    return
end

-- Subsection: package customization {{{

-- fzf-lua

local fzf_lua_highlights = vim.api.nvim_create_augroup("fzf_lua_highlights", { clear = true })

vim.api.nvim_create_autocmd("ColorScheme", {
  group = fzf_lua_highlights,
  desc = "Setup fzf-lua highlights after a colorscheme change",
  callback = require("fzf-lua").setup_highlights,
})

-- nvim-colorizer.lua
require("colorizer").setup()

-- nvim-jdtls: skipping autocmds and commands
vim.g.nvim_jdtls = 1

-- reply.vim
vim.api.nvim_create_user_command("ReplFile", function()
  vim.cmd([[call reply#command#send(join(getline(1,line("$")),"\n"),0,0)]])
end, { nargs = 0 })

-- vim-characterize

vim.keymap.set("n", "<F13>", "<Plug>(characterize)", { remap = true })
vim.api.nvim_create_user_command("Characterize", function()
  vim.cmd([[exe "normal \<F13>"]])
end, { nargs = 0 })

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

-- vim-rzip
vim.g.rzipPlugin_extra_ext = "*.odt"

-- }}}

-- vim: fdm=marker
