-- vim: fdm=marker

if vim.fn.executable("fzf") == 0 then
  return
end

local fzf = require("fzf-lua")
local actions = require("fzf-lua.actions")

local function get_history_file(suffix) -- {{{
  if vim.go.shadafile == "" then
    return
  end

  local shadafile = vim.fn.fnamemodify(vim.fn.fnamemodify(vim.go.shadafile, ":r"), ":t")

  local history_file = "fzf_history_" .. shadafile

  if suffix then
    history_file = history_file .. "_" .. suffix
  end

  return vim.fs.joinpath(vim.fn.stdpath("cache"), history_file)
end -- }}}

local function make_opts(opts) -- {{{
  opts = opts or {}

  if vim.fn.executable("nauniq") == 0 then
    return opts
  end

  local history_file = vim.tbl_get(opts, "fzf_opts", "--history")

  if not history_file then return opts end

  local cmd = "tac " .. history_file .. " | nauniq | tac | sponge " .. history_file
  -- local cmd = "tac " .. history_file .. " | nauniq | tac"
  print("cmd", vim.inspect(cmd)) -- TODO debug

  -- opts.fn_post_fzf = function()
  --   local on_exit = function(obj)
  --     print("obj", vim.inspect(obj))
  --   end
  --
  --   -- Runs asynchronously:
  --   vim.system({'wc', '-l', history_file}, { text = true }, on_exit)
  -- end
  -- opts.fn_post_fzf = function()
  --   local nauniq = vim.system({ "nauniq" }, { stdin = true }, function(obj)
  --     print("obj", vim.inspect(obj))
  --   end)
  --   local tac1 = vim.system({ "tac", history_file }, {
  --     stdout = function(err, data)
  --       assert(not err, string.format("Error running tac %s", history_file))
  --       print("data", vim.inspect(data)) -- TODO debug
  --       nauniq.write(data)
  --     end,
  --     text = true,
  --   })
  -- end
  opts.fn_post_fzf = function()
    local on_exit = function(obj)
      print("obj", vim.inspect(obj))
    end

    -- Runs asynchronously:
    vim.system({"sh", "-c", cmd}, { text = true }, on_exit)
  end

  return opts
end -- }}}

-- register fzf-lua as the UI interface for `vim.ui.select`
fzf.register_ui_select(make_opts({
  fzf_opts = { ["--history"] = get_history_file("ui_select") }
}))

local function file_switch_or_edit_or_qf(selected, opts) -- {{{
  if #selected > 1 then
    actions.file_sel_to_qf(selected, opts)
    return
  else
    local file = require("fzf-lua.path").entry_to_file(selected[1])
    require("lbrayner").jump_to_location(file.path, nil, { open_cmd = "buffer" })
  end
end -- }}}

local function file_tabedit_before(selected) -- {{{
  for _, sel in ipairs(selected) do
    local path = require("fzf-lua.path").entry_to_file(sel).path
    local vimcmd = string.format("-tabedit %s", vim.fn.fnameescape(path))
    vim.cmd(vimcmd)
  end
end -- }}}

fzf.setup({
  -- These override the default tables completely
  -- no need to set to `false` to disable an action
  -- delete or modify is sufficient
  actions = {
    files = {
      -- Pickers inheriting these actions:
      --   files, git_files, git_status, grep, lsp, oldfiles, quickfix, loclist,
      --   tags, btags, args, buffers, tabs, lines, blines
      ["enter"]       = file_switch_or_edit_or_qf,
      ["alt-g"]       = actions.file_edit_or_qf,
      ["ctrl-s"]      = actions.file_split,
      ["alt-s"]       = actions.file_vsplit,
      ["alt-t"]       = file_tabedit_before,
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
    hidden = false,
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

local function buffers() -- {{{
  fzf.buffers(make_opts({ fzf_opts = { ["--history"] = get_history_file() } }))
end -- }}}

local function fzf_files(opts) -- {{{
  opts = vim.tbl_deep_extend("keep", {
    -- https://github.com/ibhagwan/fzf-lua/issues/996
    -- actions.files refers to all pickers that deal with files which also
    -- includes grep, etc. Toggle ignore action is defined specifically for
    -- files
    actions = { ["ctrl-g"] = false },
    fzf_opts = { ["--history"] = get_history_file() }
  }, opts)

  if vim.startswith(opts.cmd, "find_file_cache") then
    opts.git_icons = false
  end

  fzf.files(make_opts(opts))
end -- }}}

local function files_clear_cache(opts) -- {{{
  opts = opts or {}
  local args = opts.args or ""
  local cmd = string.format("%s %s", "find_file_cache -C", args)

  if vim.fn.executable("find_file_cache") == 0 then
    vim.notify("find_file_cache not executable.", vim.log.levels.ERROR)
    return
  end

  fzf_files({ cmd = cmd })
  vim.notify("Cleared FZF cache.")
end -- }}}

local function files(opts) -- {{{
  opts = opts or {}
  local args = opts.args or ""
  local cmd

  if vim.fn.executable("find_file_cache") == 1 then
    cmd = "find_file_cache"
  elseif vim.fn.executable("rg") == 1 then
    cmd = "rg --files --sort path"
  end

  cmd = string.format("%s %s", cmd, args)

  fzf_files({ cmd = cmd })
end -- }}}

local function file_marks() -- {{{
  local function file_mark_jump_to_location(selected, _)
    local mark = selected[1]
    mark = mark:match("%u") -- Uppercase letters
    require("lbrayner.marks").file_mark_jump_to_location(mark)
  end

   -- Ignore error "No marks matching..."
  pcall(fzf.marks, make_opts({
    actions = {
      ["enter"] = file_mark_jump_to_location,
    },
    fzf_opts = { ["--history"] = get_history_file("file_marks") },
    marks = "[A-Z]",
    prompt = "File marks> "
  }))
end -- }}}

local function help_tags() -- {{{
  fzf.help_tags(make_opts({
    actions = { ["alt-s"] = actions.help_vert },
    fzf_opts = { ["--history"] = get_history_file("help_tags") },
  }))
end -- }}}

local function tabs() -- {{{
  fzf.tabs(make_opts({
    fzf_opts = {
      ["--history"] = get_history_file(),
      ["--preview"] = 'echo "Tab #"{2}": $(echo {1} | base64 -d -)"',
      ["--preview-window"] = "nohidden:up,1",
    },
    show_quickfix = true,
    show_unlisted = true
  }))
end -- }}}

vim.api.nvim_create_user_command("Buffers", buffers, { nargs = 0 })
vim.api.nvim_create_user_command("FilesClearCache", files_clear_cache, { complete = "file", nargs = "*" })
vim.api.nvim_create_user_command("Files", files, { complete = "file", nargs = "*" })
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
