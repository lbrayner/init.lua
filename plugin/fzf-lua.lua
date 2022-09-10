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

local function winid_from_tab_buf(tabnr, bufnr)
    local tabhandle = vim.api.nvim_list_tabpages()[tabnr]
    for _, w in ipairs(vim.api.nvim_tabpage_list_wins(tabhandle)) do
        if bufnr == vim.api.nvim_win_get_buf(w) then
            return w
        end
    end
    return nil
end

local function focus_on_selected(selected, opts)
    local tabnr, bufnr = string.match(selected[1], "^%[%s*(%d+)%]%[%s*(%d+)%]")
    local winid = winid_from_tab_buf(tonumber(tabnr), tonumber(bufnr))
    if winid then vim.api.nvim_set_current_win(winid) end
end

local function tabs()
    local tsize = #tostring(#vim.api.nvim_list_tabpages())
    local bsize = #tostring(#vim.api.nvim_list_bufs())
    local size = 1 + tsize + 1 + 1 + bsize + 1 + 1
    local contents = function(fzf_cb)
        coroutine.wrap(function()
            local co = coroutine.running()
            for i, t in ipairs(vim.api.nvim_list_tabpages()) do
                for _, w in ipairs(vim.api.nvim_tabpage_list_wins(t)) do
                    local b = vim.api.nvim_win_get_buf(w)
                    local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(b), ":~")
                    fzf_cb(string.format("[%"..tsize.."d][%"..bsize.."d] %s", i, b, name),
                    function() coroutine.resume(co) end)
                end
            end
            fzf_cb()
        end)()
    end
    local opts = {
        actions = {
            ["default"] = focus_on_selected,
        },
    }
    fzf.fzf_exec(contents, opts)
end

nvim_create_user_command("Files", files, { nargs=0 })
nvim_create_user_command("FilesClearCache", files_clear_cache, { nargs=0 })
nvim_create_user_command("Tabs", tabs, { nargs=0 })

local opts = { silent=true }

nnoremap("<F5>", fzf.buffers, opts)
nnoremap("<Leader><F7>", files_clear_cache, opts)
nnoremap("<F7>", files, opts)
nnoremap("<F8>", tabs, opts)
