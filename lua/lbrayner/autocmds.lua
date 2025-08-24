local nvim_win_get_buf = vim.api.nvim_win_get_buf
local nvim_get_current_win = vim.api.nvim_get_current_win
local nvim_buf_delete = vim.api.nvim_buf_delete
local nvim_buf_create_user_command = vim.api.nvim_buf_create_user_command
local nvim_create_augroup = vim.api.nvim_create_augroup
local nvim_create_autocmd = vim.api.nvim_create_autocmd
local nvim_get_current_buf = vim.api.nvim_get_current_buf
local nvim_buf_get_lines = vim.api.nvim_buf_get_lines
local nvim_buf_is_valid = vim.api.nvim_buf_is_valid
local nvim_exec_autocmds = vim.api.nvim_exec_autocmds
local nvim_win_get_cursor = vim.api.nvim_win_get_cursor
local nvim_buf_get_name = vim.api.nvim_buf_get_name
local nvim_buf_set_name = vim.api.nvim_buf_set_name
local nvim_tabpage_list_wins = vim.api.nvim_tabpage_list_wins
local nvim_feedkeys = vim.api.nvim_feedkeys
local nvim_replace_termcodes = vim.api.nvim_replace_termcodes
local nvim_win_close = vim.api.nvim_win_close
local nvim_get_mode = vim.api.nvim_get_mode
local cmd = vim.cmd
local schedule = vim.schedule
local tbl_contains = vim.tbl_contains
local tbl_filter = vim.tbl_filter
local startswith = vim.startswith
-- TODO sort

local aesthetics = nvim_create_augroup("aesthetics", { clear = true })

nvim_create_autocmd({ "BufWinEnter", "BufWritePost" }, {
  group = aesthetics,
  desc = "Buffer aesthetics",
  callback = function(args)
    local bufnr = args.buf
    if nvim_get_current_buf() ~= bufnr then
      -- After a BufWritePost do nothing if bufnr is not current
      return
    end
    if require("lbrayner").win_is_floating() or
      vim.bo.filetype == "fugitiveblame" or
      startswith(vim.bo.syntax, "Neogit") then
      return
    end
    require("lbrayner").set_number()
  end,
})

-- Swap | File changes outside
-- https://github.com/neovim/neovim/issues/2127
local buffer_optimization = nvim_create_augroup("buffer_optimization", { clear = true })

nvim_create_autocmd({ "BufLeave", "BufRead", "BufWritePost", "CursorHold" }, {
  group = buffer_optimization,
  desc = "Setting swapfile flag to trigger SwapExists",
  callback = function()
    if vim.bo.buftype == "" then
      vim.bo.swapfile = vim.bo.modified
    end
  end,
})

nvim_create_autocmd("SwapExists", {
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

local buffer_setup = nvim_create_augroup("buffer_setup", { clear = true })

nvim_create_autocmd("VimEnter", {
  group = buffer_setup,
  desc = "Create buffer setup autocmds",
  callback = function()
    nvim_create_autocmd("BufWinEnter", {
      pattern = "COMMIT_EDITMSG",
      group = buffer_setup,
      desc = "Buffer setup",
      callback = function(args)
        local bufnr = args.buf
        local line = nvim_buf_get_lines(bufnr, 0, 1, true)[1]

        -- If editing a commit message, do not start in insert mode
        if line == "" then
          cmd.startinsert()
        end

        vim.wo.spell = true
      end,
    })
  end,
})

if vim.v.vim_did_enter == 1 then
  nvim_exec_autocmds("VimEnter", { group = buffer_setup })
end

local checktime = nvim_create_augroup("checktime", { clear = true })

nvim_create_autocmd("VimEnter", {
  group = checktime,
  desc = "Create checktime autocmds",
  callback = function()
    nvim_create_autocmd({ "BufEnter", "FocusGained", "VimResume" }, {
      group = checktime,
      desc = "Check if file was modified outside this instance",
      callback = function()
        if vim.fn.getcmdwintype() == "" then -- E11: Invalid in command line window
          cmd.checktime()
        end
      end,
    })

    nvim_create_autocmd("User", {
      pattern = "FugitiveChanged",
      group = checktime,
      desc = "Check if file was modified by an asynchronous fugitive job",
      callback = function()
        if vim.fn.getcmdwintype() == "" then -- E11: Invalid in command line window
          local fugitive_result = vim.fn.FugitiveResult()
          if fugitive_result.capture_bufnr and type(fugitive_result.capture_bufnr) == "number" then
            cmd.checktime()
          end
        end
      end,
    })
  end,
})

if vim.v.vim_did_enter == 1 then
  nvim_exec_autocmds("VimEnter", { group = checktime })
end

local cmdwindow = nvim_create_augroup("cmdwindow", { clear = true })

nvim_create_autocmd("CmdwinEnter", {
  group = cmdwindow,
  desc = "Command-line window configuration",
  callback = function(args)
    vim.w.cmdline = true -- Performant way to know if we're in the Cmdline window
    vim.wo.spell = false
    vim.keymap.set("n", "gq", function()
      nvim_win_close(0, false)
    end, { buffer = args.buf, nowait = true })
  end,
})

local commentstring = nvim_create_augroup("commentstring", { clear = true })

nvim_create_autocmd("FileType", {
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
local default_filetype = nvim_create_augroup("default_filetype", { clear = true })

nvim_create_autocmd("VimEnter", {
  group = default_filetype,
  desc = "Create default filetype autocmds",
  callback = function()
    nvim_create_autocmd("BufEnter", {
      group = default_filetype,
      desc = "Set default filetype",
      callback = function()
        if vim.bo.filetype == "" then
          vim.b.default_filetype = true
          vim.bo.filetype = "text"
        end
      end,
    })
  end,
})

if vim.v.vim_did_enter == 1 then
  nvim_exec_autocmds("VimEnter", { group = default_filetype })
end

nvim_create_autocmd("BufWritePre", {
  group = default_filetype,
  desc = "Detect filetype after the first write",
  callback = function()
    if vim.b.default_filetype then
      vim.bo.infercase = true
      vim.bo.textwidth = nil
      vim.b.default_filetype = nil
      cmd("filetype detect")
    end
  end,
})

local help_setup = nvim_create_augroup("help_setup", { clear = true })

nvim_create_autocmd("FileType", {
  pattern = "help",
  group = help_setup,
  callback = function(args)
    local bufnr = args.buf
    schedule(function()
      if nvim_buf_is_valid(bufnr) then
        vim.keymap.set("n", "q", function()
          nvim_win_close(0, false)
        end, { buffer = bufnr, nowait = true })
      end
    end)
  end,
})

local insert_mode_undo_point = nvim_create_augroup("insert_mode_undo_point", { clear = true })

nvim_create_autocmd("CursorHoldI", {
  group = insert_mode_undo_point,
  desc = "Insert mode undo point",
  callback = function()
    if nvim_get_mode()["mode"] == "i" then
      nvim_feedkeys(nvim_replace_termcodes("<C-G>u", true, false, true), "m", false)
    end
  end,
})

local file_type_setup = nvim_create_augroup("file_type_setup", { clear = true })

nvim_create_autocmd("FileType", {
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
    elseif tbl_contains({ "html", "javascriptreact", "typescriptreact", "xml" }, filetype) then
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

local large_file = nvim_create_augroup("large_file", { clear = true })

nvim_create_autocmd("Syntax", {
  pattern = { "json", "html", "xml" },
  group = large_file,
  desc = "Disable syntax for large files",
  callback = function(args)
    local bufnr = args.buf
    local size = tonumber(vim.fn.wordcount()["bytes"])

    if size > 1024 * 512 then
      schedule(function()
        -- Buffer might be gone
        if nvim_buf_is_valid(bufnr) then
          vim.bo[bufnr].syntax = "large_file"
        end
      end)

      -- Folds are slow
      -- There are vim-fugitive mappings that open windows and tabs
      nvim_create_autocmd("WinEnter", {
        buffer = bufnr,
        once = true,
        callback = function()
          schedule(function()
            cmd("normal! zR") -- Open all folds
          end)
        end,
      })
    end
  end,
})

local protected_files = nvim_create_augroup("protected_files", { clear = true })

nvim_create_autocmd("BufRead", {
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
  local linenr = nvim_win_get_cursor(0)[1]
  cmd.wincmd("p") -- TODO to avoid https://github.com/vim/vim/issues/12436
  cmd(linenr .. command)
  vim.go.switchbuf = switchbuf
end

local function display_error_cmd(ex)
  local command = "cc"
  if require("lbrayner").is_location_list() then
    command = "ll"
  end
  local switchbuf = vim.go.switchbuf
  vim.go.switchbuf = "uselast"
  local linenr = nvim_win_get_cursor(0)[1]
  cmd.wincmd("p")
  cmd(ex)
  cmd(linenr .. command)
  vim.go.switchbuf = switchbuf
end

local qf_setup = nvim_create_augroup("qf_setup", { clear = true })

nvim_create_autocmd("FileType", {
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
      nvim_win_close(0, false)
    end, { buffer = bufnr, nowait = true })

    local wininfos = tbl_filter(function(wininfo)
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
          name = vim.fn.fnamemodify(nvim_buf_get_name(qfitem.bufnr), ":~")
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
      nvim_buf_create_user_command(bufnr, "QFFileNamesToArgList", function()
        cmd("%argdelete")
        vim.iter(get_file_names()):each(function(f)
          cmd.argadd(vim.fn.fnameescape(f))
        end)
      end, { nargs = 0 })
      nvim_buf_create_user_command(bufnr, "QFYankFileNames", function()
        local names = get_file_names()
        vim.fn.setreg('"', names)
        vim.fn.setreg("+", names)
        vim.fn.setreg("*", names)
      end, { nargs = 0 })
    end
  end,
})

local session_configuration = nvim_create_augroup("session_configuration", { clear = true })

-- SessionLoadPost happens before VimEnter
nvim_create_autocmd("VimEnter", {
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

    pcall(cmd.exe, [["normal! \<C-W>="]]) -- Equalize windows
  end,
})

local set_file_type = nvim_create_augroup("set_file_type", { clear = true })

nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
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

nvim_create_autocmd("BufRead", {
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

local terminal_setup = nvim_create_augroup("terminal_setup", { clear = true })

nvim_create_autocmd("TermOpen", {
  group = terminal_setup,
  desc = "Terminal filetype",
  callback = function()
    if vim.b.default_filetype then
      vim.bo.filetype = "terminal"
    end
  end,
})

nvim_create_autocmd("FileType", {
  pattern = "terminal",
  group = terminal_setup,
  desc = "Fix terminal title and set keymaps",
  callback = function(args)
    local bufnr = args.buf

    schedule(function()
      if not nvim_buf_is_valid(bufnr) then
        return
      end

      -- Find first window in current tab visiting this buffer
      local winid = vim.fn.win_findbuf(bufnr)[1]

      -- Specifically trying to exclude fzf-lua buffers
      if vim.bo[bufnr].filetype == "terminal" and winid == nvim_get_current_win() then
        vim.wo.relativenumber = true
      end

      if nvim_buf_get_name(bufnr) ~= vim.b[bufnr].term_title then
        local title = vim.b[bufnr].term_title
        local wrong_title = nvim_buf_get_name(bufnr)
        if not startswith(title, "term://") then
          title = string.format("%s (%d)", vim.b[bufnr].term_title, vim.fn.jobpid(vim.bo[bufnr].channel))
        end
        nvim_buf_set_name(bufnr, title)
        local wrong_title_bufnr = vim.fn.bufnr(wrong_title)
        nvim_buf_delete(wrong_title_bufnr, { force = true })
      end

      vim.keymap.set("n", "<A-h>", [[<C-\><C-N><C-W>h]], { buffer = bufnr })
      vim.keymap.set("n", "<A-j>", [[<C-\><C-N><C-W>j]], { buffer = bufnr })
      vim.keymap.set("n", "<A-k>", [[<C-\><C-N><C-W>k]], { buffer = bufnr })
      vim.keymap.set("n", "<A-l>", [[<C-\><C-N><C-W>l]], { buffer = bufnr })
    end)
  end,
})

nvim_create_autocmd("BufWinEnter", {
  pattern = "term://*",
  group = terminal_setup,
  desc = "Line numbers are not helpful in terminal buffers",
  callback = function()
    vim.wo.number = false
  end,
})

nvim_create_autocmd("TermEnter", {
  group = terminal_setup,
  callback = function()
    if not require("lbrayner").win_is_floating() then
      local terminals = tbl_filter(function(winid)
        local bufnr = nvim_win_get_buf(winid)
        return vim.bo[bufnr].buftype == "terminal"
      end, nvim_tabpage_list_wins(0))
      if vim.tbl_count(terminals) > 1 then
        vim.opt.winhighlight:append({ Normal = "CursorLine" })
      end
    end
  end,
})

nvim_create_autocmd("TermLeave", {
  group = terminal_setup,
  callback = function()
    vim.opt.winhighlight:remove({ "Normal" })
  end,
})

nvim_create_autocmd("VimEnter", {
  group = terminal_setup,
  desc = "Create terminal setup autocmds",
  callback = function()
    nvim_create_autocmd("TermOpen", {
      group = terminal_setup,
      desc = "Start in Insert Mode in terminal mode",
      callback = function(args)
        local bufnr = args.buf
        local filetype = vim.bo[bufnr].filetype

        if startswith(filetype, "dapui") then
          return
        end

        cmd.startinsert()
      end,
    })
  end,
})

if vim.v.vim_did_enter == 1 then
  nvim_exec_autocmds("VimEnter", { group = terminal_setup })
end
