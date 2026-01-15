local fzf = require "fzf".fzf
local concat = table.concat

local utils = require "fzf-commands.utils"

local fn, api = utils.helpers()

local function files(opts)
  opts = utils.normalize_opts(opts)
  local executable
  if fn.executable("fd") == 1 then
     executable = "fd"
  else
     -- tail to get rid of current directory from the results
     executable = "find"
  end

  local command = "rg --files --sort path"

  local fzf_cli_args = opts.fzf_cli_args or ""

  coroutine.wrap(function ()
    local choices = opts.fzf(
      command,
      concat({
        fzf_cli_args,
        "--ansi --expect=ctrl-s,ctrl-t,ctrl-v --multi"
      }, " ")
    )

    if not choices then return end

    local vimcmd
    if choices[1] == "ctrl-t" then
      vimcmd = "tabnew"
    elseif choices[1] == "ctrl-v" then
      vimcmd = "vnew"
    elseif choices[1] == "ctrl-s" then
      vimcmd = "new"
    else
      vimcmd = "e"
    end

    for i=2,#choices do
      vim.cmd(vimcmd .. " " .. fn.fnameescape(choices[i]))
    end

  end)()
end

return files
