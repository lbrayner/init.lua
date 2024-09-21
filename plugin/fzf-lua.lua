local success, fzf = pcall(require, "fzf-lua")

if not success then
  return
end

if vim.fn.executable("fzf") == 0 then
  return
end

if vim.fn.isdirectory(vim.fs.normalize("~/.fzf")) == 1 then
  vim.opt.runtimepath:append(vim.fs.normalize("~/.fzf"))
elseif vim.fn.isdirectory("/usr/share/doc/fzf/examples") == 1 then -- Linux
  vim.opt.runtimepath:append("/usr/share/doc/fzf/examples")
else
  return
end

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
      ["enter"]       = actions.file_edit,
      ["ctrl-s"]      = actions.file_split,
      ["alt-s"]       = actions.file_vsplit,
      ["ctrl-t"]      = actions.file_tabedit,
    },
    files = {
      -- providers that inherit these actions:
      --   files, git_files, git_status, grep, lsp, oldfiles, quickfix, loclist,
      --   tags, btags, args, buffers, tabs, lines, blines
      ["enter"]       = actions.file_edit_or_qf,
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
  mark = mark:match("%u") -- Uppercase letters
  require("lbrayner.marks").file_mark_jump_to_location(mark)
end

local function get_history_file(suffix)
  local session = require("lbrayner").get_session()
  if session then
    local history_file = "fzf_history_" .. session
    if suffix then
      history_file = history_file .. "_" .. suffix
    end
    return vim.fs.joinpath(vim.fn.stdpath("cache"), history_file)
  end
end

local function buffers()
  fzf.buffers({ fzf_opts = { ["--history"] = get_history_file() } })
end

local function fzf_files(options)
  options = vim.tbl_deep_extend("keep", {
    -- https://github.com/ibhagwan/fzf-lua/issues/996
    -- actions.files refers to all pickers that deal with files which also
    -- includes grep, etc. Toggle ignore action is defined specifically for
    -- files
    actions = { ["ctrl-g"] = false },
    fzf_opts = { ["--history"] = get_history_file() }
  }, options)

  fzf.files(options)
end

local function files_clear_cache()
  if vim.fn.executable("find_file_cache") == 0 then
    vim.notify("find_file_cache not executable.", vim.log.levels.ERROR)
    return
  end

  fzf_files({ cmd = "find_file_cache -C" })
  vim.notify("Cleared FZF cache.")
end

local function file_marks()
   -- Ignore error "No marks matching..."
  pcall(fzf.marks, {
    actions = {
      ["enter"] = file_mark_jump_to_location,
    },
    fzf_opts = { ["--history"] = get_history_file("file_marks") },
    marks = "[A-Z]",
    prompt = "File marks> "
  })
end

local function files()
  local cmd

  if vim.fn.executable("find_file_cache") == 1 then
    cmd = "find_file_cache"
  end

  fzf_files({ cmd = cmd })
end

local function help_tags()
  fzf.help_tags({
    actions = { ["alt-s"] = actions.help_vert },
    fzf_opts = { ["--history"] = get_history_file("help_tags") },
  })
end

local function tabs()
  fzf.tabs({
    fzf_opts = {
      ["--history"] = get_history_file(),
      ["--preview"] = 'echo "Tab #"{2}": $(echo {1} | base64 -d -) ["{3}"]"',
      ["--preview-window"] = "nohidden:up,1",
    },
    show_quickfix = true,
    show_unlisted = true
  })
end

vim.api.nvim_create_user_command("Buffers", buffers, { nargs = 0 })
vim.api.nvim_create_user_command("FilesClearCache", files_clear_cache, { nargs = 0 })
vim.api.nvim_create_user_command("Files", files, { nargs = 0 })
vim.api.nvim_create_user_command("HelpTags", help_tags, { nargs = 0 })
vim.api.nvim_create_user_command("Marks", file_marks, { nargs = 0 })
vim.api.nvim_create_user_command("Tabs", tabs, { nargs = 0 })

local opts = { silent = true }

vim.keymap.set("n", "<F1>", help_tags, opts)
vim.keymap.set("n", "<F4>", file_marks, opts)
vim.keymap.set("n", "<F5>", buffers, opts)
vim.keymap.set("n", "<Leader><F7>", files_clear_cache, opts)
vim.keymap.set("n", "<F7>", files, opts)
vim.keymap.set("n", "<F8>", tabs, opts)

local fzf_lua_highlights = vim.api.nvim_create_augroup("fzf_lua_highlights", { clear = true })

vim.api.nvim_create_autocmd("ColorScheme", {
  group = fzf_lua_highlights,
  desc = "Setup fzf-lua highlights after a colorscheme change",
  callback = require("fzf-lua").setup_highlights,
})

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
