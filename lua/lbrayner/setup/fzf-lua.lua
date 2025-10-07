-- vim: fdm=marker

local actions = require("fzf-lua.actions")
local concat = table.concat
local fzf = require("fzf-lua")
local get_visual_selection = require("lbrayner").get_visual_selection
local notify = vim.notify
local nvim_buf_get_mark = vim.api.nvim_buf_get_mark
local nvim_create_augroup = vim.api.nvim_create_augroup
local nvim_create_autocmd = vim.api.nvim_create_autocmd
local nvim_create_user_command = vim.api.nvim_create_user_command

-- register fzf-lua as the UI interface for `vim.ui.select`
fzf.register_ui_select(require("lbrayner.fzf-lua").make_opts({
  fzf_opts = {
    ["--history"] = require("lbrayner.fzf-lua").get_history_file("ui_select")
  }
}))

local function file_switch_or_edit_or_qf(selected, opts) -- {{{
  if #selected > 1 then
    actions.file_sel_to_qf(selected, opts)
    return
  else
    local file = require("fzf-lua.path").entry_to_file(selected[1])
    local filename = file.path

    if file.terminal then
      filename = file.stripped
    end

    require("lbrayner").jump_to_location(filename, nil, { open_cmd = "" })
  end
end -- }}}

local function file_tabedit_before(selected) -- {{{
  for _, sel in ipairs(selected) do
    local entry = require("fzf-lua.path").entry_to_file(sel)

    if entry.bufnr then
      vim.cmd(concat({ "-tabnew | setlocal bufhidden=wipe | buffer ", entry.bufnr }))
      return
    end

    vim.cmd(concat({ "-tabedit ", vim.fn.fnameescape(entry.path) }))
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

local fzf_lua_highlights = nvim_create_augroup("fzf_lua_highlights", { clear = true })

nvim_create_autocmd("ColorScheme", {
  group = fzf_lua_highlights,
  desc = "Setup fzf-lua highlights after a colorscheme change",
  callback = fzf.setup_highlights,
})

local fzf_lua_qf = nvim_create_augroup("fzf_lua_qf", { clear = true })

nvim_create_autocmd("FileType", {
  group = fzf_lua_qf,
  desc = "Fzf-lua quickfix setup",
  pattern = "qf",
  callback = function(args)
    local bufnr = args.buf
    vim.keymap.set("n", "<F5>", fzf.quickfix, { buffer = bufnr })
    vim.keymap.set("n", "<F7>", fzf.quickfix_stack, { buffer = bufnr })
  end,
})

local function get_visual_selection_query(opts) -- {{{
  local success, result = get_visual_selection(opts)

  if success then
    return result[1]
  end

  if result == 1 then
    notify("Line range not allowed, only visual selection.")
  elseif result == 2 then
    notify("Visual selection query cannot span multiple lines.")
  end
end -- }}}

nvim_create_user_command("Buffers", function()
  require("lbrayner.fzf-lua").buffers()
end, { nargs = 0 })
nvim_create_user_command("Files", function(opts)
  local args = opts.args
  local query = get_visual_selection_query(opts)

  require("lbrayner.fzf-lua").files({
    lbrayner = { args = args }, query = query
  })
end, { complete = "file", nargs = "*", range = -1 })
nvim_create_user_command("HelpTags", function()
  require("lbrayner.fzf-lua").help_tags()
end, { nargs = 0 })
nvim_create_user_command("Marks", function()
  require("lbrayner.fzf-lua").file_marks()
end, { nargs = 0 })
nvim_create_user_command("Tabs", function(opts)
  local query = get_visual_selection_query(opts)

  require("lbrayner.fzf-lua").tabs({ query = query })
end, { nargs = 0, range = -1 })
