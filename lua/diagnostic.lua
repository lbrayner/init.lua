local api = vim.api

-- Requires Neovim 0.7.0+
if not api["nvim_create_autocmd"] then
    return
end

local function open_float()
    -- Save the current cursor position
    local line_col = api.nvim_win_get_cursor(0)
    -- Move the cursor to the beginning of the line
    api.nvim_win_set_cursor(0,{ line_col[1], 0 })
    local next_pos = vim.diagnostic.get_next_pos()
    -- If there's no next diagnostic on the current line, there might be one on
    -- column 1
    if not next_pos or next_pos[1]+1 ~= line_col[1] then
        -- If there isn't, restore the cursor
        return vim.diagnostic.open_float() or api.nvim_win_set_cursor(0, line_col)
    end
    -- Move the cursor to the first diagnostic on the line
    api.nvim_win_set_cursor(0, { line_col[1], next_pos[2] })
    local _, win_id = vim.diagnostic.open_float({ close_events={} })
    -- The following snippet is adapted from $VIMRUNTIME/lua/vim/lsp/util.lua
    local augroup_name = "preview_window_" .. win_id
    local augroup = api.nvim_create_augroup(augroup_name, {
        clear = true,
    })
    local create_autocmd = function()
        api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "InsertCharPre" }, {
            buffer = api.nvim_get_current_buf(),
            group = augroup,
            callback = function()
                api.nvim_del_augroup_by_name(augroup_name)
                return api.nvim_win_is_valid(win_id) and api.nvim_win_close(win_id, true)
            end,
        })
    end
    -- Deferring the creation of the autocommand because nvim_win_set_cursor
    -- triggers CursorMoved
    vim.defer_fn(create_autocmd, 150)
end

local opts = { noremap=true, silent=true }

vim.keymap.set("n", "<space>e",  open_float, opts)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

api.nvim_create_user_command("DiagnosticSetLocationList",
    vim.diagnostic.setloclist, { nargs = 0 })
