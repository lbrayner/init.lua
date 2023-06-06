if vim.fn.executable("fzf") == 0 then
  return
end

if vim.fn.isdirectory(vim.fn.fnamemodify("~/.fzf", ":p")) then
  vim.cmd "set rtp+=~/.fzf"
elseif vim.fn.isdirectory("/usr/share/doc/fzf/examples") then -- Linux
  vim.cmd "set rtp+=/usr/share/doc/fzf/examples"
else
  return
end

local nvim_create_user_command = vim.api.nvim_create_user_command
local fzf = require("fzf-lua")
local actions = require "fzf-lua.actions"

fzf.setup {
  buffers = {
    actions = {
      ["ctrl-v"] = false,
      ["alt-s"]  = actions.buf_vsplit,
    },
    previewer = false,
  },
  files = {
    actions = {
      ["ctrl-v"] = false,
      ["alt-s"]  = actions.file_vsplit,
    },
    previewer = false,
  },
  tabs = {
    actions = {
      ["ctrl-v"] = false,
      ["alt-s"]  = actions.buf_vsplit,
    },
    previewer = false,
  },
}

local function files()
  if vim.fn.executable("find_file_cache") > 0 then
    return fzf.files({ cmd="find_file_cache" })
  end
  fzf.files()
end

local function files_clear_cache()
  if vim.fn.executable("find_file_cache") > 0 then
    return fzf.files({ cmd="find_file_cache -C" })
  end
  vim.cmd.echoerr("'find_file_cache not executable.'")
end

nvim_create_user_command("Files", files, { nargs=0 })
nvim_create_user_command("FilesClearCache", files_clear_cache, { nargs=0 })
nvim_create_user_command("Tabs", fzf.tabs, { nargs=0 })

local opts = { silent=true }

vim.keymap.set("n", "<F5>", fzf.buffers, opts)
vim.keymap.set("n", "<Leader><F7>", files_clear_cache, opts)
vim.keymap.set("n", "<F7>", files, opts)
vim.keymap.set("n", "<F8>", function()
  fzf.tabs({ show_quickfix=true })
end, opts)
