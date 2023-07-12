if vim.fn.executable("fzf") == 0 then
  return
end

if vim.fn.isdirectory(vim.fn.fnamemodify("~/.fzf", ":p")) then
  vim.cmd "set rtp+=~/.fzf"
elseif vim.fn.isdirectory("/usr/share/doc/fzf/examples") then -- Linux
  vim.cmd "set rtp+=/usr/share/doc/fzf/examples"
else
  return
end

local nvim_create_user_command = vim.api.nvim_create_user_command
local fzf = require("fzf-lua")
local actions = require("fzf-lua.actions")

-- register fzf-lua as the UI interface for `vim.ui.select`
fzf.register_ui_select()

fzf.setup({
  -- These override the default tables completely
  -- no need to set to `false` to disable an action
  -- delete or modify is sufficient
  actions = {
    files = {
      -- providers that inherit these actions:
      --   files, git_files, git_status, grep, lsp
      --   oldfiles, quickfix, loclist, tags, btags
      --   args
      ["default"]     = actions.file_edit_or_qf,
      ["ctrl-s"]      = actions.file_split,
      ["alt-s"]       = actions.file_vsplit,
      ["ctrl-t"]      = actions.file_tabedit,
      ["alt-q"]       = actions.file_sel_to_qf,
      ["alt-l"]       = actions.file_sel_to_ll,
    },
    buffers = {
      -- providers that inherit these actions:
      --   buffers, tabs, lines, blines
      ["default"]     = actions.buf_edit,
      ["ctrl-s"]      = actions.buf_split,
      ["alt-s"]       = actions.buf_vsplit,
      ["ctrl-t"]      = actions.buf_tabedit,
    }
  },
  buffers = {
    no_header_i = true, -- So that no header is displayed (can be accomplished with { ["ctrl-x"] = false }
    previewer = false,
  },
  files = {
    previewer = false,
  },
  keymap = {
    fzf = {}, -- completely overriding fzf '--bind=' options
  },
  quickfix = {
    previewer = false,
  },
  quickfix_stack = {
    previewer = false,
  },
  tabs = {
    no_header_i = true, -- So that no header is displayed (can be accomplished with { ["ctrl-x"] = false }
    previewer = false,
  },
  winopts = {
    preview = {
      layout = "vertical",
    },
  },
})

local function buffers()
  local fzf_opts
  local success, session = pcall(require, "lbrayner.session.fzf")

  if success then
    fzf_opts = { ["--history"] = session.get_history_file() }
  end

  fzf.buffers({ fzf_opts = fzf_opts })
end

local function files_clear_cache()
  if vim.fn.executable("find_file_cache") == 0 then
    return vim.cmd.echoerr("'find_file_cache not executable.'")
  end

  local fzf_opts
  local success, session = pcall(require, "lbrayner.session.fzf")

  if success then
    fzf_opts = { ["--history"] = session.get_history_file() }
  end

  fzf.files({ cmd = "find_file_cache -C", fzf_opts = fzf_opts })
end

local function file_marks()
  fzf.marks({ marks = "A-Z", prompt = "File marks> " })
end

local function files()
  local cmd
  local fzf_opts
  local success, session = pcall(require, "lbrayner.session.fzf")

  if success then
    fzf_opts = { ["--history"] = session.get_history_file() }
  end

  if vim.fn.executable("find_file_cache") > 0 then
    cmd = "find_file_cache"
  end
  fzf.files({ cmd = cmd, fzf_opts = fzf_opts })
end

local function tabs()
  local fzf_opts
  local success, session = pcall(require, "lbrayner.session.fzf")

  if success then
    fzf_opts = { ["--history"] = session.get_history_file() }
  end

  fzf.tabs({ fzf_opts = fzf_opts, show_quickfix = true })
end

nvim_create_user_command("Buffers", buffers, { nargs = 0 })
nvim_create_user_command("FilesClearCache", files_clear_cache, { nargs = 0 })
nvim_create_user_command("Files", files, { nargs = 0 })
nvim_create_user_command("Marks", file_marks, { nargs = 0 })
nvim_create_user_command("Tabs", tabs, { nargs = 0 })

local opts = { silent = true }

vim.keymap.set("n", "<F5>", buffers, opts)
vim.keymap.set("n", "<Leader><F7>", files_clear_cache, opts)
vim.keymap.set("n", "<F7>", files, opts)
vim.keymap.set("n", "<F8>", tabs, opts)

local fzf_lua_qf = vim.api.nvim_create_augroup("fzf_lua_qf", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = fzf_lua_qf,
  desc = "Fzf-lua quickfix setup",
  pattern = "qf",
  callback = function(args)
    local bufnr = args.buf
    vim.keymap.set("n", "<F5>", fzf.quickfix, { buffer = bufnr })
    vim.keymap.set("n", "<F7>", fzf.quickfix_stack, { buffer = bufnr })
  end,
})
