-- vim: fdm=marker

local concat = table.concat
local fnameescape = vim.fn.fnameescape
local fzf = require("fzf").fzf
local shellescape = vim.fn.shellescape
local utils = require("fzf-commands.utils")

local SPLIT      = "ctrl-s"
local TAB        = "ctrl-t"
local TAB_BEFORE = "alt-t"
local VSPLIT     = "alt-s"

local function jump(selected) -- {{{
  if #selected > 2 then
    -- vim.schedule(function()
    --   vim.api.nvim_echo({ { "[FZF files] Cannot jump to multiple files", "Normal" } }, true, {})
    -- end)
    -- vim.notify("[FZF files] Cannot jump to multiple files", vim.log.levels.WARN)
    -- vim.cmd.redraw()
    return
  else
    local bufnr = vim.fn.bufadd(selected[2])
    require("lbrayner").jump_to_location(bufnr)
  end
end -- }}}

local function tabedit_before(selected) -- {{{
  for i=2, #selected do
    local bufnr = vim.fn.bufadd(selected[i])
    -- from fzf-lua's actions (vimcmd_entry)
    vim.cmd(concat({ "-tabnew | setlocal bufhidden=wipe | buffer ", bufnr }))
  end
end -- }}}

return function (opts)
  opts = utils.normalize_opts(opts)
  local command = "rg --files --sort path"
  local fzf_cli_args = concat({
    "--ansi --multi --expect=",
    shellescape(concat({ SPLIT, TAB, TAB_BEFORE, VSPLIT }, ",")),
    opts.fzf_cli_args and concat({ " ", opts.fzf_cli_args }) or "",
  })

  coroutine.wrap(function ()
    local selected = opts.fzf(command, fzf_cli_args)

    if not selected then return end

    local action = selected[1]
    local vicmd

    if action == SPLIT then
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
