local aesthetics = vim.api.nvim_create_augroup("aesthetics", { clear = true })

vim.api.nvim_create_autocmd({ "BufWinEnter", "BufWritePost" }, {
  group = aesthetics,
  desc = "Buffer aesthetics",
  callback = function(args)
    local bufnr = args.buf
    if vim.api.nvim_get_current_buf() ~= bufnr then
      -- After a BufWritePost do nothing if bufnr is not current
      return
    end
    if require("lbrayner").win_is_floating() or
      vim.bo.filetype == "fugitiveblame" or
      vim.startswith(vim.bo.syntax, "Neogit") then
      return
    end
    require("lbrayner").set_number()
  end,
})

-- Swap | File changes outside
-- https://github.com/neovim/neovim/issues/2127
local buffer_optimization = vim.api.nvim_create_augroup("buffer_optimization", { clear = true })

vim.api.nvim_create_autocmd({ "BufLeave", "BufRead", "BufWritePost", "CursorHold" }, {
  group = buffer_optimization,
  desc = "Setting swapfile flag to trigger SwapExists",
  callback = function(args)
    if vim.bo.buftype == "" then
      vim.bo.swapfile = vim.bo.modified
    end
  end,
})

vim.api.nvim_create_autocmd("SwapExists", {
  group = buffer_optimization,
  desc = "Automatically delete old swap files",
  callback = function(args)
    -- if swapfile is older than file itself, just get rid of it
    if vim.fn.getftime(vim.v.swapname) < vim.fn.getftime(args.file) then
      vim.fn.delete(vim.v.swapname)
      vim.v.swapchoice = "e"
    end
  end,
})

local buffer_setup = vim.api.nvim_create_augroup("buffer_setup", { clear = true })

vim.api.nvim_create_autocmd("VimEnter", {
  group = buffer_setup,
  desc = "Create buffer setup autocmds",
  callback = function()
    vim.api.nvim_create_autocmd("BufWinEnter", {
      pattern = "COMMIT_EDITMSG",
      group = buffer_setup,
      desc = "Buffer setup",
      callback = function(args)
        local bufnr = args.buf
        local line = vim.api.nvim_buf_get_lines(bufnr, 0, 1, true)[1]

        -- If editing a commit message, do not start in insert mode
        if line == "" then
          vim.cmd.startinsert()
        end

        vim.wo.spell = true
      end,
    })
  end,
})

if vim.v.vim_did_enter == 1 then
  vim.api.nvim_exec_autocmds("VimEnter", { group = buffer_setup })
end

local checktime = vim.api.nvim_create_augroup("checktime", { clear = true })

vim.api.nvim_create_autocmd("VimEnter", {
  group = checktime,
  desc = "Create checktime autocmds",
  callback = function()
    vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "VimResume" }, {
      group = checktime,
      desc = "Check if file was modified outside this instance",
      callback = function()
        if vim.fn.getcmdwintype() == "" then -- E11: Invalid in command line window
          vim.cmd.checktime()
        end
      end,
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = "FugitiveChanged",
      group = checktime,
      desc = "Check if file was modified by an asynchronous fugitive job",
      callback = function()
        if vim.fn.getcmdwintype() == "" then -- E11: Invalid in command line window
          local fugitive_result = vim.fn.FugitiveResult()
          if fugitive_result.capture_bufnr and type(fugitive_result.capture_bufnr) == "number" then
            vim.cmd.checktime()
          end
        end
      end,
    })
  end,
})

if vim.v.vim_did_enter == 1 then
  vim.api.nvim_exec_autocmds("VimEnter", { group = checktime })
end

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
  desc = "Create default filetype autocmds",
  callback = function()
    vim.api.nvim_create_autocmd("BufEnter", {
      group = default_filetype,
      desc = "Set default filetype",
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
    "gitcommit", "html", "java", "javascriptreact", "lua", "mail", "markdown", "sql",
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
    elseif filetype == "java" then
      vim.b.match_words = "<:>"
    elseif filetype == "lua" then
      vim.bo.includeexpr = "v:lua.require'lbrayner'.include_expression(v:fname)"
      vim.opt_local.suffixesadd:remove(".lua")
    elseif filetype == "mail" then
      vim.bo.infercase = true
      require("lbrayner").setup_xml_matchit()
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

local large_file = vim.api.nvim_create_augroup("large_file", { clear = true })

vim.api.nvim_create_autocmd("Syntax", {
  pattern = { "json", "html", "xml" },
  group = large_file,
  desc = "Disable syntax for large files",
  callback = function(args)
    local bufnr = args.buf
    local size = tonumber(vim.fn.wordcount()["bytes"])

    if size > 1024 * 512 then
      vim.schedule(function()
        -- Buffer might be gone
        if vim.api.nvim_buf_is_valid(bufnr) then
          vim.bo[bufnr].syntax = "large_file"
        end
      end)

      -- Folds are slow
      -- There are vim-fugitive mappings that open windows and tabs
      vim.api.nvim_create_autocmd("WinEnter", {
        buffer = bufnr,
        once = true,
        callback = function()
          vim.schedule(function()
            vim.cmd("normal! zR") -- Open all folds
          end)
        end,
      })
    end
  end,
})

local protected_files = vim.api.nvim_create_augroup("protected_files", { clear = true })

vim.api.nvim_create_autocmd("BufRead", {
  pattern = {
    "*/node_modules/*",
    vim.fs.joinpath(vim.g.rocks_nvim.rocks_path, "share/*"),
    vim.fs.normalize("~/.local/share/virtualenvs/*"),
    vim.fs.normalize("~/.m2/repository/*"),
    vim.fs.normalize("~/.pyenv/versions/*/lib/*"),
  },
  group = protected_files,
  desc = "Protected files (such as package manager controlled files) should not be writeable",
  callback = function()
    vim.bo.modifiable = false
  end,
})

local function display_error_switchbuf(swb)
  local command = "cc"
  if require("lbrayner").is_location_list() then
    command = "ll"
  end
  local switchbuf = vim.go.switchbuf
  vim.go.switchbuf = swb
  local linenr = vim.api.nvim_win_get_cursor(0)[1]
  vim.cmd.wincmd("p") -- TODO to avoid https://github.com/vim/vim/issues/12436
  vim.cmd(linenr .. command)
  vim.go.switchbuf = switchbuf
end

local function display_error_cmd(cmd)
  local command = "cc"
  if require("lbrayner").is_location_list() then
    command = "ll"
  end
  local switchbuf = vim.go.switchbuf
  vim.go.switchbuf = "uselast"
  local linenr = vim.api.nvim_win_get_cursor(0)[1]
  vim.cmd.wincmd("p")
  vim.cmd(cmd)
  vim.cmd(linenr .. command)
  vim.go.switchbuf = switchbuf
end

local qf_setup = vim.api.nvim_create_augroup("qf_setup", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = qf_setup,
  desc = "Quickfix setup",
  pattern = "qf",
  callback = function(args)
    local bufnr = args.buf

    vim.keymap.set("n", "o", function()
      display_error_switchbuf("usetab,split")
    end, { buffer = bufnr })
    vim.keymap.set("n", "O", function()
      display_error_switchbuf("usetab,vsplit")
    end, { buffer = bufnr })
    vim.keymap.set("n", "<Tab>", function()
      display_error_switchbuf("usetab,newtab")
    end, { buffer = bufnr })

    vim.keymap.set("n", "<Leader>o", function()
      display_error_cmd("split")
    end, { buffer = bufnr })
    vim.keymap.set("n", "<Leader>O", function()
      display_error_cmd("vsplit")
    end, { buffer = bufnr })
    vim.keymap.set("n", "<Leader><Tab>", function()
      display_error_cmd("tabnew")
    end, { buffer = bufnr })

    vim.keymap.set("n", "q", function()
      vim.api.nvim_win_close(0, false)
    end, { buffer = bufnr, nowait = true })

    local wininfos = vim.tbl_filter(function(wininfo)
      return wininfo.bufnr == bufnr
    end, vim.fn.getwininfo())

    for _, wininfo in ipairs(wininfos) do
      local winid = wininfo.winid
      vim.wo[winid].spell = false
      vim.wo[winid].wrap = false
    end

    local function get_file_names()
      local names = vim.empty_dict()
      for _, qfitem in ipairs(vim.fn.getqflist()) do
        local name
        if qfitem.bufnr > 0 then
          name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(qfitem.bufnr), ":~")
        else
          name = vim.fn.fnamemodify(qfitem.text, ":p:~")
        end
        if not names[name] then
          names[name] = true
        end
      end
      return vim.tbl_keys(names)
    end

    -- https://github.com/wincent/ferret: ferret#private#qargs()
    if require("lbrayner").is_quickfix_list() then
      vim.api.nvim_buf_create_user_command(bufnr, "QFFileNamesToArgList", function()
        vim.cmd("%argdelete")
        vim.iter(get_file_names()):each(function(f)
          vim.cmd.argadd(vim.fn.fnameescape(f))
        end)
      end, { nargs = 0 })
      vim.api.nvim_buf_create_user_command(bufnr, "QFYankFileNames", function()
        local names = get_file_names()
        vim.fn.setreg('"', names)
        vim.fn.setreg("+", names)
        vim.fn.setreg("*", names)
      end, { nargs = 0 })
    end
  end,
})

local session_configuration = vim.api.nvim_create_augroup("session_configuration", { clear = true })

-- SessionLoadPost happens before VimEnter
vim.api.nvim_create_autocmd("VimEnter", {
  group = session_configuration,
  desc = "Session configuration",
  callback = function()
    if vim.v.this_session == "" then return end

    require("lbrayner.wipe").loop_buffers(true, function(buf) -- BWipeNotReadable!
      return (
        buf.listed == 1 and
        vim.bo[buf.bufnr].buftype ~= "terminal" and
        not vim.uv.fs_stat(buf.name)
      )
    end)

    pcall(vim.cmd.exe, [["normal! \<C-W>="]]) -- Equalize windows
  end,
})

local set_file_type = vim.api.nvim_create_augroup("set_file_type", { clear = true })

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = {
    "*/host_vars/*", "*.wsdl", ".ignore", ".ripgreprc*", "ignore", "ripgreprc*"
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
    elseif extension == "wsdl" then
      vim.bo.filetype = "xml"
    elseif require("lbrayner").contains(file, "/host_vars/") then
      vim.bo.filetype = "yaml"
    end
  end,
})

vim.api.nvim_create_autocmd("BufRead", {
  pattern = {
    "*/jre*/lib/security/java.policy", "/tmp/dir*"
  },
  group = set_file_type,
  desc = "Setting filetype for files that users normally just edit or view",
  callback = function(args)
    local file = args.match
    local filename = vim.fn.fnamemodify(file, ":t")

    if filename == "java.policy" then
      vim.bo.filetype = "groovy"
    elseif vim.fn.argc() == 1 and string.find(vim.fn.argv(0), "^/tmp/dir%w%w%w%w%w$") then
      vim.bo.filetype = "vidir"
    end
  end,
})

local terminal_setup = vim.api.nvim_create_augroup("terminal_setup", { clear = true })

vim.api.nvim_create_autocmd("TermOpen", {
  group = terminal_setup,
  desc = "Terminal filetype",
  callback = function()
    if vim.b.default_filetype then
      vim.bo.filetype = "terminal"
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "terminal",
  group = terminal_setup,
  desc = "Fix terminal title and set keymaps",
  callback = function(args)
    local bufnr = args.buf

    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(bufnr) then
        return
      end

      -- Find first window in current tab visiting this buffer
      local winid = vim.fn.win_findbuf(bufnr)[1]

      -- Specifically trying to exclude fzf-lua buffers
      if vim.bo[bufnr].filetype == "terminal" and winid == vim.api.nvim_get_current_win() then
        vim.wo.relativenumber = true
      end

      if vim.api.nvim_buf_get_name(bufnr) ~= vim.b[bufnr].term_title then
        local title = vim.b[bufnr].term_title
        local wrong_title = vim.api.nvim_buf_get_name(bufnr)
        if not vim.startswith(title, "term://") then
          title = string.format("%s (%d)", vim.b[bufnr].term_title, vim.fn.jobpid(vim.bo[bufnr].channel))
        end
        vim.api.nvim_buf_set_name(bufnr, title)
        local wrong_title_bufnr = vim.fn.bufnr(wrong_title)
        vim.api.nvim_buf_delete(wrong_title_bufnr, { force = true })
      end

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

vim.api.nvim_create_autocmd("TermEnter", {
  group = terminal_setup,
  callback = function()
    if not require("lbrayner").win_is_floating() then
      local terminals = vim.tbl_filter(function(winid)
        local bufnr = vim.api.nvim_win_get_buf(winid)
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

vim.api.nvim_create_autocmd("VimEnter", {
  group = terminal_setup,
  desc = "Create terminal setup autocmds",
  callback = function()
    vim.api.nvim_create_autocmd("TermOpen", {
      group = terminal_setup,
      desc = "Start in Insert Mode in terminal mode",
      callback = function(args)
        local bufnr = args.buf
        local filetype = vim.bo[bufnr].filetype

        if vim.startswith(filetype, "dapui") then
          return
        end

        vim.cmd.startinsert()
      end,
    })
  end,
})

if vim.v.vim_did_enter == 1 then
  vim.api.nvim_exec_autocmds("VimEnter", { group = terminal_setup })
end

local write_shada = vim.api.nvim_create_augroup("write_shada", { clear = true })
local write_shada_timer

vim.api.nvim_create_autocmd("FocusGained", {
  group = write_shada,
  desc = "Write ShaDa file",
  callback = function()
    if write_shada_timer and write_shada_timer:is_closing() then
      return
    end

    write_shada_timer:stop()
    write_shada_timer:close()
  end,
})

vim.api.nvim_create_autocmd("FocusLost", {
  group = write_shada,
  desc = "Maybe abort ShaDa file write",
  callback = function()
    if write_shada_timer and not write_shada_timer:is_closing() then
      return
    end

    write_shada_timer = vim.uv.new_timer()

    write_shada_timer:start(60000, 0, vim.schedule_wrap(function()
      pcall(vim.cmd, "wshada!")
      vim.notify("Wrote ShaDa file", vim.log.levels.WARN)
      write_shada_timer:close()
    end))
  end,
})
