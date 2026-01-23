-- vim: fdm=marker

local bufadd = vim.fn.bufadd
local concat = table.concat
local fnameescape = vim.fn.fnameescape
local get_cwd = require("lbrayner.path").get_cwd
local shellescape = vim.fn.shellescape

local EDIT       = "ctrl-]"
local SPLIT      = "ctrl-s"
local TAB        = "ctrl-t"
local TAB_BEFORE = "alt-t"
local VSPLIT     = "alt-s"

local PATH_SEPARATOR = package.config:sub(1,1)

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
  local bufnr = bufadd(selected[2])
  require("lbrayner").jump_to_location(bufnr)
end -- }}}

local function tabedit_before(selected) -- {{{
  for i = 2, #selected do
    local bufnr = bufadd(selected[i])
    -- from fzf-lua's actions (vimcmd_entry)
    vim.cmd(concat({ "-tabnew | setlocal bufhidden=wipe | buffer ", bufnr }))
  end
end -- }}}

return function (opts)
  opts = opts or {}
  local command = concat(
    { "rg --files --sort path", opts.fzf_command_args }, " "
  )
  print("command", vim.inspect(command)) -- TODO debug
  local history_file = require("lbrayner.nvim-fzf.history").get_history_file()

  local fzf_cli_args = concat({
    "--multi", concat({ "--history=", shellescape(history_file) }),
    concat({
      "--expect=", shellescape(concat({ EDIT, SPLIT, TAB, TAB_BEFORE, VSPLIT }, ","))
    }),
    concat({ "--prompt=", shellescape(get_cwd()), PATH_SEPARATOR }),
    opts.fzf_cli_args and opts.fzf_cli_args or nil
  }, " ")
  -- print("fzf_cli_args", vim.inspect(fzf_cli_args)) -- TODO debug

  coroutine.wrap(function()
    local selected = require("fzf").fzf(command, fzf_cli_args)

    if selected then
      (function()
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

        for i = 2, #selected do
          vim.cmd(concat({ vicmd, fnameescape(selected[i]) }, " "))
        end
      end)()
    end

    require("lbrayner.nvim-fzf.history").sanitize_history_file(history_file)
  end)()
end
