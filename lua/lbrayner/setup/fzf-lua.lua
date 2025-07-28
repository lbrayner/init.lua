-- vim: fdm=marker

local actions = require("fzf-lua.actions")
local fzf = require("fzf-lua")
local get_history_file = require("lbrayner.fzf-lua").get_history_file
local make_opts = require("lbrayner.fzf-lua").make_opts

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
    require("lbrayner").jump_to_location(file.path, nil, { open_cmd = "" })
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

vim.api.nvim_create_user_command("Buffers", function()
  require("lbrayner.fzf-lua").buffers()
end, { nargs = 0 })
vim.api.nvim_create_user_command("FilesClearCache", function(opts)
  require("lbrayner.fzf-lua").files_clear_cache(opts)
end, { complete = "file", nargs = "*" })
vim.api.nvim_create_user_command("Files", function(opts)
  require("lbrayner.fzf-lua").files(opts)
end, { complete = "file", nargs = "*" })
vim.api.nvim_create_user_command("HelpTags", function()
  require("lbrayner.fzf-lua").help_tags()
end, { nargs = 0 })
vim.api.nvim_create_user_command("Marks", function()
  require("lbrayner.fzf-lua").file_marks()
end, { nargs = 0 })
vim.api.nvim_create_user_command("Tabs", function()
  require("lbrayner.fzf-lua").tabs()
end, { nargs = 0 })
