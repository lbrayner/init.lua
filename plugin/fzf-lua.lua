if vim.fn.executable("fzf") == 0 then
    return
end

if vim.fn.isdirectory(os.getenv("HOME") .. "/.fzf") then
    vim.cmd "set rtp+=~/.fzf"
elseif vim.fn.isdirectory("/usr/share/doc/fzf/examples") then -- Linux
    vim.cmd "set rtp+=/usr/share/doc/fzf/examples"
else
    return
end

vim.cmd.packadd "fzf-lua"

local nvim_create_user_command = vim.api.nvim_create_user_command
local fzf = require("fzf-lua")
local keymap = require("lbrayner.keymap")
local nnoremap = keymap.nnoremap

fzf.setup {
    buffers = {
        previewer = false,
    },
    files = {
        previewer = false,
    },
    tabs = {
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
    vim.cmd("echoerr 'find_file_cache not executable.'")
end

nvim_create_user_command("LFiles", files, { nargs=0 })
nvim_create_user_command("LCFiles", files_clear_cache, { nargs=0 })

local opts = { silent=true }

nnoremap("<F5>", fzf.buffers, opts)
nnoremap("<Leader><F7>", files_clear_cache, opts)
nnoremap("<F7>", files, opts)
nnoremap("<Leader><F8>", fzf.tabs, opts)
