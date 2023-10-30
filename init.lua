-- Subsection: settings {{{

vim.go.backspace =  "indent,eol,start"
vim.go.backupcopy = "yes" -- So that watchprocesses work as expected
vim.go.breakindent = true
vim.go.completeopt = "menuone"
vim.go.cursorline = true
vim.go.expandtab = true
vim.go.fileformat = "unix"
vim.go.fileformats = "unix,dos"
vim.go.ignorecase = true
vim.go.lazyredraw = true
vim.go.linebreak = true
vim.go.listchars = "eol:¬,tab:» ,trail:·"
vim.go.number = true
vim.go.relativenumber = true
vim.go.ruler = false
vim.go.shiftwidth = 2 -- when indenting with '>', use 2 spaces width
vim.go.showmode = false
vim.go.smartcase = true
vim.go.splitbelow = true
vim.go.splitright = true
vim.go.switchbuf = "usetab,uselast"
vim.go.synmaxcol = 500 -- From tpope's vim-sensible (lowering this improves performance in files with long lines)
vim.go.tabstop = 4 -- show existing tab with 4 spaces width
if vim.env.TERM == "foot" or string.find(vim.env.TERM, "256color") then
    vim.go.termguicolors = true
end
vim.go.title = true
vim.go.wildmenu = true
vim.go.wildmode = "longest:full"

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

-- https://vim.fandom.com/wiki/Converting_variables_to_or_from_camel_case
-- Convert from score_case to camelCase
vim.keymap.set("n", "crc", [[:s#\%\(\<[a-z_]\w\{-}\)\@<=_\(\a\)#\u\1#g]])
-- Convert from camelCase to score_case
vim.keymap.set("n", "cr_", [[:s#\(\<\u\l\+\|\l\+\)\(\u\)#\l\1_\l\2#g]])

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
    vim.cmd(string.format([[keeppatterns %d,%ds/\s\+$//e]], command.line1, command.line2))
  end)
end, { bar = true, nargs = 0, range = "%" })
vim.keymap.set("ca", "D", "DeleteTrailingWhitespace")

local function number()
  vim.wo.number = true
  vim.wo.relativenumber = true
  -- setting nonumber if length of line count is greater than 3
  if #tostring(vim.fn.line("$")) > 3 then
    vim.wo.number = false
  end
end

vim.api.nvim_create_user_command("Number", number, { nargs = 0 })

-- https://vi.stackexchange.com/a/36414
local function source(line_start, line_end, vimscript)
  local tempfile = vim.fn.tempname()

  if not vimscript then
    tempfile = tempfile..".lua"
  end

  vim.cmd(string.format("silent %d,%dwrite %s", line_start, line_end, vim.fn.fnameescape(tempfile)))
  vim.cmd.source(vim.fn.fnameescape(tempfile))
  vim.fn.delete(tempfile)

  if line_start == line_end then
    vim.cmd.echomsg(string.format("'Sourced line %d.'", line_start))
    return
  end

  vim.cmd.echomsg(string.format("'Sourced lines %d to %d.'", line_start, line_end))
end

vim.api.nvim_create_user_command("Source", function(command)
  source(command.line1, command.line2)
end, { nargs = 0, range = true })
vim.api.nvim_create_user_command("VimscriptSource", function(command)
  source(command.line1, command.line2, true)
end, { nargs = 0, range = true })

vim.api.nvim_create_user_command("Filter", function(command)
  local line_start = command.line1
  local line_end = command.line2
  local offset = 0
  for linenr = line_start, line_end do
    vim.api.nvim_win_set_cursor(0, { linenr + offset, 0 })
    local output = vim.fn.systemlist(vim.fn.getline(linenr + offset))
    vim.cmd.delete()
    vim.fn.append(linenr + offset - 1, output)
    if not vim.tbl_isempty(output) then
      offset = offset + #output - 1
    end
  end
  vim.api.nvim_win_set_cursor(0, { line_start, 0 })
end, { nargs = 0, range = true })

-- Human-readable stack of syntax items
vim.api.nvim_create_user_command("Synstack", function()
  local pos = vim.api.nvim_win_get_cursor(0)
  local synstack = vim.fn.synstack(pos[1], pos[2] + 1)
  -- map(synstack(line("."), col(".")), "synIDattr(v:val, 'name')")
  local syn_id_addrs = vim.tbl_map(function(item)
    return vim.fn.synIDattr(item, "name")
  end, synstack)
  print(vim.inspect(syn_id_addrs))
end, { nargs = 0 })

-- Delete file marks
vim.api.nvim_create_user_command("Delfilemarks", require("lbrayner.marks").delete_file_marks, { nargs = 0 })

-- }}}

-- Ripgrep

vim.go.grepprg = "rg --vimgrep"
vim.go.grepformat = "%f:%l:%c:%m"
vim.go.shellpipe = "&>"

vim.api.nvim_create_user_command("Rg", function(command)
  local txt = command.args
  local ripgrep = require("lbrayner.ripgrep")
  local success, err = pcall(ripgrep.rg, txt)

  if not success then
    vim.cmd.cclose()
    if type(err) == "string" and string.find(err, " Rg:") then
      vim.cmd.echoerr(string.format('"%s"', vim.fn.escape(err, '"')))
      return
    end
    vim.cmd.echomsg(string.format('"Error searching for %s. Unmatched quotes? Check your command."',
      vim.fn.escape(txt, '"')))
    return
  end

  if not vim.tbl_isempty(vim.fn.getqflist()) then
    vim.cmd("botright copen")
  else
    vim.cmd.cclose()
    vim.cmd.echomsg(string.format('"No match found for %s."', vim.fn.escape(txt, '"')))
  end
end, { complete = "file", nargs = "*" })

vim.keymap.set("ca", "Rg", "Rg -e")
vim.keymap.set("ca", "Rb", [[Rg -s -e'\b''''\b'<Left><Left><Left><Left><Left>]])
vim.keymap.set("ca", "Rw", [[Rg -s -e'\b''<C-R><C-W>''\b']])

-- Subsection: autocmds {{{

local cmdwindow = vim.api.nvim_create_augroup("cmdwindow", { clear = true })
vim.api.nvim_create_autocmd("CmdwinEnter", {
  group = cmdwindow,
  desc = "Disable spell in Command-line window",
  callback = function()
    vim.wo.spell = false
  end,
})

local commentstring = vim.api.nvim_create_augroup("commentstring", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "apache", "crontab", "debsources", "desktop", "fstab", "samba" },
  group = commentstring,
  desc = "Pound comment",
  callback = function()
    vim.bo.commentstring = "# %s"
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "sql",
  group = commentstring,
  desc = "SQL comment",
  callback = function()
    vim.bo.commentstring = "-- %s"
  end,
})

local insert_mode_undo_point = vim.api.nvim_create_augroup("insert_mode_undo_point", { clear = true })
vim.api.nvim_create_autocmd("CursorHoldI", {
  group = insert_mode_undo_point,
  desc = "Insert mode undo point",
  callback = function()
    if vim.fn.mode() ~= "i" then -- TODO use Neovim API
      return
    end
    vim.cmd([[call feedkeys("\<C-G>u")]]) -- TODO use Neovim API
  end,
})

local aesthetics = vim.api.nvim_create_augroup("aesthetics", { clear = true })

vim.api.nvim_create_autocmd({ "BufWinEnter", "BufWritePost" }, {
  group = aesthetics,
  desc = "Buffer aesthetics",
  callback = function()
    if require("lbrayner").window_is_floating() then
      return
    end
    if vim.bo.filetype == "fugitiveblame" then
      return
    end
    if vim.startswith(vim.bo.syntax, "Neogit") then
      return
    end
    number()
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "help",
  group = aesthetics,
  callback = function(args)
    vim.api.nvim_create_autocmd("BufEnter", {
      group = aesthetics,
      buffer = args.buf,
      desc = "Aesthetics for help buffers",
      callback = function()
        vim.wo.relativenumber = true
      end,
    })
  end,
})

local set_file_type = vim.api.nvim_create_augroup("set_file_type", { clear = true })

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  group = set_file_type,
  desc = "Setting filetype for various patterns",
  callback = function(args)
    local extension = vim.fn.fnamemodify(args.file, ":e")
    local filename = vim.fn.fnamemodify(args.file, ":t")

    if filename == ".ignore" then
      vim.bo.filetype = "gitignore"
    end

    if extension == "redis" then
      vim.bo.filetype = "redis"
    end

    if extension == "wsdl" then
      vim.bo.filetype = "xml"
    end
  end,
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = "/tmp/dir*",
  group = set_file_type,
  desc = "Vidir filetype",
  callback = function()
    if vim.fn.argc() == 1 and string.find(vim.fn.argv(0), "^/tmp/dir%w%w%w%w%w$") then
      vim.bo.filetype = "vidir"
    end
  end,
})

vim.api.nvim_create_autocmd("TermOpen", {
  group = set_file_type,
  desc = "Terminal filetype",
  callback = function()
    vim.bo.filetype = "terminal"
  end,
})

-- Simulate Emacs' Fundamental mode
local default_file_type = vim.api.nvim_create_augroup("default_file_type", { clear = true })

vim.api.nvim_create_autocmd("BufEnter", {
  group = default_file_type,
  desc = "Set default filetype",
  callback = function()
    if vim.bo.filetype == "" then
      vim.bo.filetype = "text"
      vim.b.default_filetype = true
    end
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  group = default_file_type,
  desc = "Detect filetype after the first write",
  callback = function()
    if vim.b.default_file_type then
      vim.bo.infercase = true
      vim.bo.textwidth = nil
      vim.b.default_filetype = nil
      vim.cmd("filetype detect")
    end
  end,
})

local large_xml_file = 1024 * 512
local large_xml = vim.api.nvim_create_augroup("large_xml", { clear = true })

vim.api.nvim_create_autocmd("BufRead", {
  group = large_xml,
  desc = "Disable syntax for large XML files",
  callback = function(args)
    if vim.bo.filetype == "html" or vim.bo.filetype == "xml" then
      if vim.fn.getfsize(args.file) > large_xml_file then
        vim.bo.syntax = "unkown"
      end
    end
  end,
})

local file_type_setup = vim.api.nvim_create_augroup("file_type_setup", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = file_type_setup,
  desc = "Filetype setup for various patterns",
  callback = function(args)
    local bufnr = args.buf
    local filetype = args.match

    if vim.tbl_contains({ "gitcommit", "mail", "markdown", "text" }, filetype) then
      vim.bo.infercase = true
    end

    if vim.tbl_contains({ "html", "javascriptreact", "typescriptreact", "xml" }, filetype) then
      vim.keymap.set("n", "[<", "<Cmd>call xml#NavigateDepthBackward(v:count1)<CR>", {
        buffer = bufnr, silent = true })
      vim.keymap.set("n", "]<", "<Cmd>call xml#NavigateDepth(v:count1)<CR>", {
        buffer = bufnr, silent = true })
    end

    if vim.bo.filetype == "mail" then
      vim.cmd("call util#setupMatchit()")
    end

    if vim.bo.filetype == "markdown" then
      vim.bo.tabstop = 2
      vim.bo.textwidth = 80
    end

    if vim.bo.filetype == "sql" then
      vim.bo.indentexpr = "indent"
    end

    if vim.bo.filetype == "text" then
      vim.bo.textwidth = 80
    end
  end,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
  pattern = "COMMIT_EDITMSG",
  group = file_type_setup,
  desc = "Start in insert mode",
  callback = function()
    vim.cmd.startinsert()
  end,
})

local session_load = vim.api.nvim_create_augroup("session_load", { clear = true })
vim.api.nvim_create_autocmd("SessionLoadPost", {
  group = session_load,
  desc = "Wipe buffers without files on session load",
  callback = function()
    vim.api.nvim_create_autocmd("VimEnter", {
      group = session_load,
      callback = function()
        vim.cmd("silent BWipeNotReadable!")
      end,
    })
  end,
})

local terminal_setup = vim.api.nvim_create_augroup("terminal_setup", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "terminal",
  group = terminal_setup,
  desc = "Fix terminal title on session load",
  callback = function(args)
    vim.api.nvim_create_autocmd("BufEnter", {
      group = terminal_setup,
      buffer = args.buf,
      once = true,
      callback = function(args)
        local bufnr = args.buf
        vim.schedule(function()
          vim.api.nvim_buf_set_name(bufnr, vim.b[bufnr].term_title)
        end)
      end,
    })
  end,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
  pattern = "term://*",
  group = terminal_setup,
  desc = "Line numbers are not helpful in terminal buffers",
  callback = function()
    vim.wo.number = false
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  group = terminal_setup,
  desc = "Start in terminal mode",
  callback = function()
    vim.api.nvim_create_autocmd("TermOpen", {
      group = terminal_setup,
      callback = function()
        vim.cmd.startinsert()
      end,
    })
  end,
})

if vim.v.vim_did_enter == 1 then
  vim.api.nvim_exec_autocmds("VimEnter", { group = terminal_setup })
end

local tab_events = vim.api.nvim_create_augroup("tab_events", { clear = true })
vim.api.nvim_create_autocmd("TabClosed", {
  group = tab_events,
  desc = "Returning to previous tab instead of next",
  callback = function(args)
    local tab = tonumber(args.file)

    if tab > 1 and tab <= vim.fn.tabpagenr("$") then
      vim.cmd.tabprevious()
    end
  end,
})

local node_js = vim.api.nvim_create_augroup("node_js", { clear = true })
vim.api.nvim_create_autocmd({ "BufReadPost", "VimEnter" }, {
  pattern = "**/node_modules/*",
  group = node_js,
  desc = "NPM modules should not writeable",
  callback = function()
    vim.bo.modifiable = false
  end,
})

-- }}}

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
vim.api.nvim_create_user_command("ReplFile", [[call reply#command#send(join(getline(1,line("$")),"\n"),0,0)]], {
  nargs = 0 })

-- vim-characterize

vim.keymap.set("n", "<F13>", "<Plug>(characterize)", { remap = true })
vim.api.nvim_create_user_command("Characterize", [[exe "normal \<F13>"]], { nargs = 0 })

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
