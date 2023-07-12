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
    buffers = {
      -- providers that inherit these actions:
      --   buffers, tabs, lines, blines
      ["default"]     = actions.buf_edit,
      ["ctrl-s"]      = actions.buf_split,
      ["alt-s"]       = actions.buf_vsplit,
      ["ctrl-t"]      = actions.buf_tabedit,
    },
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

local function file_mark_jump_to_location(selected, _)
  local mark = selected[1]
  mark = "'" .. mark:match("%u") -- Uppercase letters
  local file_mark_by_mark, _ = require("lbrayner.marks").file_mark_navigator()
  local file_mark = file_mark_by_mark[mark]
  local filename = file_mark.file
  -- Full path because tilde is not expanded in lua
  filename = vim.fn.fnamemodify(filename, ":p")
  local pos = { file_mark.pos[2], (file_mark.pos[3] - 1) }
  require("lbrayner").jump_to_location(filename, pos)
end

local function history_file()
  local session = require("lbrayner").get_session()
  if session then
    return string.format("%s/fzf_history_%s", vim.fn.stdpath("cache"), session)
  end
end

local function buffers()
  fzf.buffers({ fzf_opts = { ["--history"] = history_file() } })
end

local function files_clear_cache()
  if vim.fn.executable("find_file_cache") == 0 then
    return vim.cmd.echoerr("'find_file_cache not executable.'")
  end

  fzf.files({ cmd = "find_file_cache -C", fzf_opts = { ["--history"] = history_file() } })
end

local function file_marks()
   -- Ignore error "No marks matching..."
  pcall(fzf.marks, {
    actions = {
      ["default"] = file_mark_jump_to_location,
    },
    marks = "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
    prompt = "File marks> "
  })
end

local function files()
  local cmd

  if vim.fn.executable("find_file_cache") > 0 then
    cmd = "find_file_cache"
  end

  fzf.files({ cmd = cmd, fzf_opts = { ["--history"] = history_file() } })
end

local function tabs()
  fzf.tabs({ fzf_opts = { ["--history"] = history_file() }, show_quickfix = true })
end

nvim_create_user_command("Buffers", buffers, { nargs = 0 })
nvim_create_user_command("FilesClearCache", files_clear_cache, { nargs = 0 })
nvim_create_user_command("Files", files, { nargs = 0 })
nvim_create_user_command("Marks", file_marks, { nargs = 0 })
nvim_create_user_command("Tabs", tabs, { nargs = 0 })

local opts = { silent = true }

vim.keymap.set("n", "<F4>", file_marks, opts)
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
