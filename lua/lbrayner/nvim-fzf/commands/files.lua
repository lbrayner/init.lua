-- vim: fdm=marker

local fzf = require "fzf".fzf
local concat = table.concat
local shellescape = vim.fn.shellescape

local utils = require "fzf-commands.utils"

local fn, api = utils.helpers()

local function file_jump(selected) -- {{{
  if #selected > 2 then
    vim.notify("Cannot jump to multiple files.", vim.log.levels.WARN)
    return
  else
    local bufnr = vim.fn.bufadd(selected[2])
    require("lbrayner").jump_to_location(bufnr)
  end
end -- }}}

local function file_tabedit_before(selected) -- {{{
  for i=2, #selected do
    local bufnr = vim.fn.bufadd(selected[i])
    -- from fzf-lua's actions (vimcmd_entry)
    vim.cmd(concat({ "-tabnew | setlocal bufhidden=wipe | buffer ", bufnr }))
  end
end -- }}}

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

  local fzf_cli_args = concat({
    opts.fzf_cli_args or "",
    " --ansi --multi --expect=",
    shellescape("alt-s,alt-t,ctrl-s,ctrl-t,ctrl-]")
  })
  print("fzf_cli_args", fzf_cli_args) -- TODO debug

  coroutine.wrap(function ()
    local selected = opts.fzf(command, fzf_cli_args)

    if not selected then return end

    local key = selected[1]

    local vimcmd
    if key == "alt-t" then
      file_tabedit_before(selected)
      return
    elseif key == "alt-s" then
      vimcmd = "vnew"
    elseif key == "ctrl-s" then
      vimcmd = "new"
    else
      file_jump(selected)
      return
    end

    for i=2,#selected do
      vim.cmd(vimcmd .. " " .. fn.fnameescape(selected[i]))
    end

  end)()
end

return files
