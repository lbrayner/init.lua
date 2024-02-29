-- Subsection: settings {{{

vim.go.backspace =  "indent,eol,start"
vim.go.backupcopy = "yes"
vim.go.breakindent = true
vim.go.clipboard = "unnamed,unnamedplus"
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
vim.go.shiftwidth = 2
vim.go.showmode = false
vim.go.smartcase = true
vim.go.splitbelow = true
vim.go.splitright = true
vim.go.switchbuf = "usetab,uselast"
vim.go.synmaxcol = 500 -- From tpope's vim-sensible (lowering this improves performance in files with long lines)
vim.go.tabstop = 2
vim.go.termguicolors = true
vim.go.title = true
vim.go.wildmenu = true
vim.go.wildmode = "longest:full"

-- }}}

-- Subsection: mappings — pt-BR keyboard {{{

-- remapping leader to comma
vim.g.mapleader = ","

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
vim.keymap.set("n", "<Leader>x", [[:keepp %s/\C\V\<<C-R><C-W>\>//gc<Left><Left><Left>]])
-- Rename visual selection
vim.keymap.set("v", "<Leader>x", [[""y:keepp %s/\C\V<C-R>"//gc<Left><Left><Left>]])

-- https://vim.fandom.com/wiki/Converting_variables_to_or_from_camel_case
-- Convert from score_case to camelCase
vim.keymap.set("n", "crc", [[:keepp s#\%\(\<[a-z_]\w\{-}\)\@<=_\(\a\)#\u\1#g]])
-- Convert from camelCase to score_case
vim.keymap.set("n", "cr_", [[:keepp s#\(\<\u\l\+\|\l\+\)\(\u\)#\l\1_\l\2#g]])

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
  local syn_id_addrs = vim.tbl_map(function(item)
    return vim.fn.synIDattr(item, "name")
  end, synstack)
  print(vim.inspect(syn_id_addrs))
end, { nargs = 0 })

-- https://stackoverflow.com/a/2573758
-- Inspired by the TabMessage function/command combo found at <http://www.jukie.net/~bart/conf/vimrc>.
vim.api.nvim_create_user_command("RedirMessages", function(command)
  vim.cmd("redir => message")
  vim.cmd(string.format("silent %s", command.args))
  vim.cmd("redir END")
  vim.cmd("silent put=message")
end, { complete = "command", nargs = "+" })

-- }}}

-- Variables

-- See $VIMRUNTIME/ftplugin/markdown.vim
vim.g.markdown_recommended_style = 0

-- Modules

require("lbrayner.clipboard")
require("lbrayner.flash")
require("lbrayner.highlight")
require("lbrayner.marks")
require("lbrayner.ripgrep")
require("lbrayner.statusline")
require("lbrayner.tabline")

-- Subsection: autocmds {{{

local aesthetics = vim.api.nvim_create_augroup("aesthetics", { clear = true })
vim.api.nvim_create_autocmd({ "BufWinEnter", "BufWritePost" }, {
  group = aesthetics,
  desc = "Buffer aesthetics",
  callback = function()
    if require("lbrayner").window_is_floating() or
      vim.bo.filetype == "fugitiveblame" or
      vim.startswith(vim.bo.syntax, "Neogit") then
      return
    end
    number()
  end,
})

local cmdwindow = vim.api.nvim_create_augroup("cmdwindow", { clear = true })
vim.api.nvim_create_autocmd("CmdwinEnter", {
  group = cmdwindow,
  desc = "Command-line window configuration",
  callback = function(args)
    vim.w.cmdline = true -- Performant way to know if we're in the Cmdline window
    vim.wo.spell = false
    vim.keymap.set("n", "gq", function()
      vim.api.nvim_win_close(0, false)
    end, { buffer = args.buf, nowait = true })
  end,
})

local commentstring = vim.api.nvim_create_augroup("commentstring", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "apache", "crontab", "debsources", "desktop", "fstab", "samba", "sql" },
  group = commentstring,
  desc = "Set commentstring",
  callback = function(args)
    local filetype = args.match
    if filetype == "sql" then
      vim.bo.commentstring = "-- %s"
    else
      vim.bo.commentstring = "# %s"
    end
  end,
})

-- Simulate Emacs' Fundamental mode
local default_filetype = vim.api.nvim_create_augroup("default_filetype", { clear = true })

vim.api.nvim_create_autocmd("VimEnter", {
  group = default_filetype,
  desc = "Set default filetype",
  callback = function()
    vim.api.nvim_create_autocmd("BufEnter", {
      group = default_filetype,
      callback = function(args)
        local bufnr = args.buf
        if vim.bo.filetype == "" then
          vim.b.default_filetype = true
          vim.bo.filetype = "text"
        end
      end,
    })
  end,
})

if vim.v.vim_did_enter == 1 then
  vim.api.nvim_exec_autocmds("VimEnter", { group = default_filetype })
end

vim.api.nvim_create_autocmd("BufWritePre", {
  group = default_filetype,
  desc = "Detect filetype after the first write",
  callback = function(args)
    if vim.b.default_filetype then
      vim.bo.infercase = true
      vim.bo.textwidth = nil
      vim.b.default_filetype = nil
      vim.cmd("filetype detect")
    end
  end,
})

local help_setup = vim.api.nvim_create_augroup("help_setup", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  pattern = "help",
  group = help_setup,
  callback = function(args)
    vim.schedule(function()
      vim.wo.relativenumber = true
      vim.keymap.set("n", "q", function()
        vim.api.nvim_win_close(0, false)
      end, { buffer = args.buf, nowait = true })
    end)
  end,
})

local insert_mode_undo_point = vim.api.nvim_create_augroup("insert_mode_undo_point", { clear = true })
vim.api.nvim_create_autocmd("CursorHoldI", {
  group = insert_mode_undo_point,
  desc = "Insert mode undo point",
  callback = function()
    if vim.api.nvim_get_mode()["mode"] ~= "i" then
      return
    end
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-G>u", true, false, true), "m", false)
  end,
})

local file_type_setup = vim.api.nvim_create_augroup("file_type_setup", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "gitcommit", "html", "javascriptreact", "lua", "mail", "markdown", "sql",
    "text", "typescriptreact", "xml"
  },
  group = file_type_setup,
  desc = "Filetype setup",
  callback = function(args)
    local bufnr = args.buf
    local filetype = args.match

    if filetype == "gitcommit" then
      vim.bo.infercase = true
    elseif vim.tbl_contains({ "html", "javascriptreact", "typescriptreact", "xml" }, filetype) then
      vim.keymap.set("n", "[<", function()
        require("lbrayner").navigate_depth_backward(vim.v.count1)
      end, { buffer = bufnr, silent = true })
      vim.keymap.set("n", "]<", function()
        require("lbrayner").navigate_depth(vim.v.count1)
      end, { buffer = bufnr, silent = true })
    elseif filetype == "lua" then
      vim.bo.includeexpr = "v:lua.require'lbrayner'.diff_include_expression(v:fname)"
    elseif filetype == "mail" then
      vim.bo.infercase = true
      require("lbrayner").setup_matchit()
    elseif filetype == "markdown" then
      vim.bo.infercase = true
      vim.bo.textwidth = 80
    elseif filetype == "sql" then
      vim.bo.indentexpr = "indent"
    elseif filetype == "text" then
      vim.bo.infercase = true
      if not vim.b.default_filetype then
        vim.bo.textwidth = 80
      end
    end
  end,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
  pattern = "COMMIT_EDITMSG",
  group = file_type_setup,
  desc = "Start in insert mode",
  callback = function()
    vim.cmd.startinsert()
    vim.bo.spelllang = "en"
    vim.wo.spell = true
  end,
})

local large_xml_file = 1024 * 512
local large_xml = vim.api.nvim_create_augroup("large_xml", { clear = true })
vim.api.nvim_create_autocmd("Syntax", {
  pattern = { "html", "xml" },
  group = large_xml,
  desc = "Disable syntax for large XML files",
  callback = function(args)
    if vim.fn.getfsize(args.file) > large_xml_file then
      vim.schedule(function()
        vim.bo.syntax = "large_file"
      end)
    end
  end,
})

local package_manager = vim.api.nvim_create_augroup("package_manager", { clear = true })
vim.api.nvim_create_autocmd("BufRead", {
  pattern = { "**/node_modules/*", vim.fs.normalize("~/.m2/repository") .. "/*" },
  group = package_manager,
  desc = "Package manager controlled files should not writeable",
  callback = function()
    vim.bo.modifiable = false
  end,
})

local session_equalize_windows = vim.api.nvim_create_augroup("session_equalize_windows", { clear = true })
vim.api.nvim_create_autocmd("VimEnter", {
  group = session_equalize_windows,
  desc = "Equalize windows on session startup",
  callback = function()
    if vim.v.this_session == "" then return end
    pcall(vim.cmd.exe, [["normal! \<C-W>="]])
  end,
})

-- SessionLoadPost happens before VimEnter
local session_load = vim.api.nvim_create_augroup("session_load", { clear = true })
vim.api.nvim_create_autocmd("VimEnter", {
  group = session_load,
  desc = "Wipe buffers without files on session load",
  callback = function()
    if vim.v.this_session == "" then return end
    vim.cmd("silent BWipeNotReadable!")
  end,
})

local set_file_type = vim.api.nvim_create_augroup("set_file_type", { clear = true })

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = { "**/host_vars/*", "*.redis", "*.wsdl", ".ignore", "/tmp/dir*" },
  group = set_file_type,
  desc = "Setting filetype for various patterns",
  callback = function(args)
    local file = args.match
    local extension = vim.fn.fnamemodify(file, ":e")
    local filename = vim.fn.fnamemodify(file, ":t")

    if filename == ".ignore" then
      vim.bo.filetype = "gitignore"
    elseif extension == "redis" then
      vim.bo.filetype = "redis"
    elseif extension == "wsdl" then
      vim.bo.filetype = "xml"
    elseif vim.fn.argc() == 1 and string.find(vim.fn.argv(0), "^/tmp/dir%w%w%w%w%w$") then
      vim.bo.filetype = "vidir"
    elseif require("lbrayner").contains(file, "/host_vars/") then
      vim.bo.filetype = "yaml"
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

local terminal_setup = vim.api.nvim_create_augroup("terminal_setup", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "terminal",
  group = terminal_setup,
  desc = "Fix terminal title on session load",
  callback = function(args)
    local bufnr = args.buf
    vim.schedule(function()
      vim.api.nvim_buf_set_name(bufnr, vim.b[bufnr].term_title)
      vim.keymap.set("n", "<A-h>", [[<C-\><C-N><C-W>h]], { buffer = bufnr })
      vim.keymap.set("n", "<A-j>", [[<C-\><C-N><C-W>j]], { buffer = bufnr })
      vim.keymap.set("n", "<A-k>", [[<C-\><C-N><C-W>k]], { buffer = bufnr })
      vim.keymap.set("n", "<A-l>", [[<C-\><C-N><C-W>l]], { buffer = bufnr })
    end)
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
    vim.api.nvim_create_autocmd("TermEnter", {
      group = terminal_setup,
      callback = function()
        if not require("lbrayner").window_is_floating() then
          local terminals = vim.tbl_filter(function(win)
            local bufnr = vim.api.nvim_win_get_buf(win)
            return vim.bo[bufnr].buftype == "terminal"
          end, vim.api.nvim_tabpage_list_wins(0))
          if vim.tbl_count(terminals) > 1 then
            vim.opt.winhighlight:append({ Normal = "CursorLine" })
          end
        end
      end,
    })
    vim.api.nvim_create_autocmd("TermLeave", {
      group = terminal_setup,
      callback = function()
        vim.opt.winhighlight:remove({ "Normal" })
      end,
    })
  end,
})

if vim.v.vim_did_enter == 1 then
  vim.api.nvim_exec_autocmds("VimEnter", { group = terminal_setup })
end

-- }}}

local vim_dir = vim.fn.stdpath("config")

if vim.env.MYVIMRC == "" then
  vim_dir = vim.fn.expand("<sfile>:p:h")
end

-- Finish here if we haven't initialized the submodules

if vim.fn.glob(vim.fs.joinpath(vim_dir, "pack/bundle/start/*/plugin")) == "" then
  return
end

-- Subsection: packages {{{

-- fidget.nvim

-- Standalone UI for nvim-lsp progress. Eye candy for the impatient.
require("fidget").setup({
  notification = {
    window = {
      winblend = 0, -- to fix the interaction with transparent backgrounds
    },
  },
})

-- Improved alternate file mapping
vim.keymap.set("n", "<Space>a", function()
  local alternate = vim.fn.bufnr("#")
  if alternate > 0 and vim.api.nvim_buf_is_valid(alternate) then
    local name = vim.fn.pathshorten(require("lbrayner.statusline").filename(true))
    vim.api.nvim_set_current_buf(alternate)
    require("lbrayner.flash").flash_window()
    require("fidget").notify(string.format("Switched to alternate buffer. Previous buffer was %s.", name))
  else
    vim.notify("Alternate buffer is not valid.")
  end
end)

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

-- nvim-spider
vim.keymap.set({"n", "o", "x"}, "<Leader>w", "<cmd>lua require('spider').motion('w')<CR>", { desc = "Spider-w" })
vim.keymap.set({"n", "o", "x"}, "<Leader>e", "<cmd>lua require('spider').motion('e')<CR>", { desc = "Spider-e" })
vim.keymap.set({"n", "o", "x"}, "<Leader>b", "<cmd>lua require('spider').motion('b')<CR>", { desc = "Spider-b" })
vim.keymap.set({"n", "o", "x"}, "<Leader>ge", "<cmd>lua require('spider').motion('ge')<CR>", {
  desc = "Spider-ge" })

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
