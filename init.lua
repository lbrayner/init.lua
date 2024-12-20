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
require("lbrayner.wipe")

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

vim.api.nvim_create_user_command("LuaModuleReload", function(command)
  local module, replacements
  module = string.gsub(command.args, "^lua/", "")
  module, replacements = string.gsub(module, "/", ".")
  if replacements > 0 then
    module = string.gsub(module, "%.lua$", "")
  end
  package.loaded[module] = nil
  require(module)
  vim.notify(string.format("Reloaded '%s'.", module))
end, { bar = true, nargs = 1 })

-- https://stackoverflow.com/a/2573758
-- Inspired by the TabMessage function/command combo found at <http://www.jukie.net/~bart/conf/vimrc>.
vim.api.nvim_create_user_command("RedirMessages", function(command)
  vim.cmd("redir => message")
  vim.cmd(string.format("silent %s", command.args))
  vim.cmd("redir END")
  vim.cmd("silent put=message")
end, { complete = "command", nargs = "+" })

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

vim.api.nvim_create_user_command("SourceVimscript", function(command)
  source(command.line1, command.line2, true)
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

-- }}}

-- Subsection: autocmds {{{

local aesthetics = vim.api.nvim_create_augroup("aesthetics", { clear = true })

vim.api.nvim_create_autocmd({ "BufWinEnter", "BufWritePost" }, {
  group = aesthetics,
  desc = "Buffer aesthetics",
  callback = function(args)
    local bufnr = args.buf
    if vim.api.nvim_get_current_buf() ~= bufnr then
      -- After a BufWritePost, do nothing if bufnr is not current
      return
    end
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
    local bufnr = args.buf
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(bufnr) then
        vim.keymap.set("n", "q", function()
          vim.api.nvim_win_close(0, false)
        end, { buffer = bufnr, nowait = true })
      end
    end)
  end,
})

local insert_mode_undo_point = vim.api.nvim_create_augroup("insert_mode_undo_point", { clear = true })

vim.api.nvim_create_autocmd("CursorHoldI", {
  group = insert_mode_undo_point,
  desc = "Insert mode undo point",
  callback = function()
    if vim.api.nvim_get_mode()["mode"] == "i" then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-G>u", true, false, true), "m", false)
    end
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
  callback = function(args)
    local bufnr = args.buf
    vim.schedule(function()
      vim.api.nvim_buf_call(bufnr, function()
        vim.cmd.startinsert()
      end)
    end)
    vim.bo.spelllang = "en"
    vim.wo.spell = true
  end,
})

local package_manager = vim.api.nvim_create_augroup("package_manager", { clear = true })

vim.api.nvim_create_autocmd("BufRead", {
  pattern = {
    "*/node_modules/*",
    vim.fs.normalize("~/.local/share/nvim/rocks/share") .. "/*",
    vim.fs.normalize("~/.local/share/virtualenvs") .. "/*",
    vim.fs.normalize("~/.m2/repository") .. "/*",
    vim.fs.normalize("~/.pyenv/versions") .. "/*/lib/*",
  },
  group = package_manager,
  desc = "Package manager controlled files should not be writeable",
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
    require("lbrayner.wipe").loop_buffers(true, function(buf) -- BWipeNotReadable!
      return buf.listed == 1 and vim.fn.filereadable(buf.name) == 0
    end)
  end,
})

local set_file_type = vim.api.nvim_create_augroup("set_file_type", { clear = true })

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = {
    "*/host_vars/*", "*.redis", "*.wsdl", ".ignore", ".ripgreprc*", "/tmp/dir*", "ignore", "ripgreprc*"
  },
  group = set_file_type,
  desc = "Setting filetype for various patterns",
  callback = function(args)
    local file = args.match
    local extension = vim.fn.fnamemodify(file, ":e")
    local filename = vim.fn.fnamemodify(file, ":t")

    if filename == ".ignore" or filename == "ignore" then
      vim.bo.filetype = "gitignore"
    elseif string.find(filename, "^%.?ripgreprc") then
      vim.bo.filetype = "shell"
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

-- }}}

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
