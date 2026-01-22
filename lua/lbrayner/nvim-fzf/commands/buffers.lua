-- vim: fdm=marker

local ansi = require("lbrayner.nvim-fzf.utils").ansi
local concat = table.concat
local fnamemodify = vim.fn.fnamemodify
local get_buffer_info = require("lbrayner.nvim-fzf.utils").get_buffer_info
local shellescape = vim.fn.shellescape

local EDIT       = "ctrl-]"
local SPLIT      = "ctrl-s"
local TAB        = "ctrl-t"
local TAB_BEFORE = "alt-t"
local VSPLIT     = "alt-s"

local BLUE = ansi.color_to_ansi("blue")
local CLEAR = ansi.clear
local history_file = require("lbrayner.nvim-fzf.history").get_history_file()

local function edit(selected) -- {{{
  if #selected > 2 then
    vim.notify("[FZF files] Cannot edit multiple files", vim.log.levels.WARN)
  else
    local bufnr = tonumber(selected[2]:match("%d+"))
    vim.api.nvim_set_current_buf(bufnr)
  end
end -- }}}

local function jump(selected) -- {{{
  if #selected > 2 then
    vim.notify("[FZF buffers] Cannot jump to multiple buffers", vim.log.levels.WARN)
    return
  end
  local bufnr = tonumber(selected[2]:match("%d+"))
  require("lbrayner").jump_to_location(bufnr)
end -- }}}

return function (opts)
  opts = opts or {}
  local entries = {}

  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    local info = get_buffer_info(bufnr)

    table.insert(
      entries,
      ("%s[%d]%s	%s	%s"):format(
        BLUE, bufnr, CLEAR,
        info.flags, fnamemodify(info.name, ":~:.")
      )
    )
  end

  local fzf_cli_args = concat({
    "--ansi --multi --prompt='Buffers> '",
    concat({ "--history=", shellescape(history_file) }),
    concat({
      "--expect=", shellescape(concat({ EDIT, SPLIT, TAB, TAB_BEFORE, VSPLIT }, ","))
    }),
    opts.fzf_cli_args and opts.fzf_cli_args or nil
  }, " ")
  -- print("fzf_cli_args", vim.inspect(fzf_cli_args)) -- TODO debug

  coroutine.wrap(function()
    local selected = require("fzf").fzf(entries, fzf_cli_args)
    -- print("selected", vim.inspect(selected)) -- TODO debug

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
          vicmd = "-tabnew"
        elseif action == VSPLIT then
          vicmd = "vnew"
        else
          jump(selected)
          return
        end

        for i = 2, #selected do
          local bufnr = tonumber(selected[i]:match("%d+"))
          -- from fzf-lua's actions (vimcmd_entry)
          vim.cmd(concat({ vicmd, " | setlocal bufhidden=wipe | buffer ", bufnr }))
        end
      end)()
    end

    require("lbrayner.nvim-fzf.history").sanitize_history_file(history_file)
  end)()
end
