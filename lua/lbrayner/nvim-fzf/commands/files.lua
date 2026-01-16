-- vim: fdm=marker

local concat = table.concat
local fnameescape = vim.fn.fnameescape
local fzf = require("fzf").fzf
local get_cwd = require("lbrayner.path").get_cwd
local get_history_file = require("lbrayner.nvim-fzf").get_history_file
local shellescape = vim.fn.shellescape

local EDIT       = "ctrl-]"
local SPLIT      = "ctrl-s"
local TAB        = "ctrl-t"
local TAB_BEFORE = "alt-t"
local VSPLIT     = "alt-s"

local function edit(selected) -- {{{
  if #selected > 2 then
    vim.notify("[FZF files] Cannot edit multiple files", vim.log.levels.WARN)
  else
    vim.cmd(concat({ "edit ", fnameescape(selected[2]) }))
  end
end -- }}}

local function jump(selected) -- {{{
  if #selected > 2 then
    vim.notify("[FZF files] Cannot jump to multiple files", vim.log.levels.WARN)
    return
  end

  local bufnr = vim.fn.bufadd(selected[2])
  require("lbrayner").jump_to_location(bufnr)
end -- }}}

local function tabedit_before(selected) -- {{{
  for i=2, #selected do
    local bufnr = vim.fn.bufadd(selected[i])
    -- from fzf-lua's actions (vimcmd_entry)
    vim.cmd(concat({ "-tabnew | setlocal bufhidden=wipe | buffer ", bufnr }))
  end
end -- }}}

return function (opts)
  opts = opts or {}
  local command = "rg --files --sort path"
  local history_file_ = shellescape(get_history_file())

  local fzf_cli_args = concat({
    "--ansi --multi", concat({ "--history=", history_file_ }),
    concat({
      "--expect=", shellescape(concat({ EDIT, SPLIT, TAB, TAB_BEFORE, VSPLIT }, ","))
    }),
    concat({ "--prompt=", shellescape(get_cwd()), "/" }),
    opts.fzf_cli_args and opts.fzf_cli_args or nil
  }, " ")
  -- print("fzf_cli_args", vim.inspect(fzf_cli_args)) -- TODO debug

  coroutine.wrap(function ()
    local selected = fzf(command, fzf_cli_args)

    if vim.fn.executable("nauniq") == 1 then
      local cmd = concat({ "tac", history_file_, "| nauniq | tac | sponge", history_file_ }, " ")

      pcall(vim.system, { "sh", "-c", cmd }, { text = true }, vim.schedule_wrap(function(obj)
        if obj.code ~= 0 then
          vim.notify(string.format(
            "Could not run '%s': %s", cmd, obj.stderr
          ), vim.log.levels.ERROR)
        end
      end))
    end

    if not selected then return end

    local action = selected[1]
    local vicmd

    if action == EDIT then
      edit(selected)
      return
    elseif action == SPLIT then
      vicmd = "new"
    elseif action == TAB then
      vicmd = "tabnew"
    elseif action == TAB_BEFORE then
      tabedit_before(selected)
      return
    elseif action == VSPLIT then
      vicmd = "vnew"
    else
      jump(selected)
      return
    end

    for i=2, #selected do
      vim.cmd(concat({ vicmd, fnameescape(selected[i]) }, " "))
    end
  end)()
end
