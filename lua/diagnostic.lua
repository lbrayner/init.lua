local api = vim.api

local function open_float()
    local line_col = api.nvim_win_get_cursor(0)
    local next_pos = vim.diagnostic.get_next_pos()
    api.nvim_win_set_cursor(0,{ line_col[1], 0 })
    if not next_pos or next_pos[1]+1 ~= line_col[1] then
        api.nvim_win_set_cursor(0, line_col)
        return vim.diagnostic.open_float()
    end
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
                api.nvim_win_close(win_id, true)
            end,
        })
    end
    -- Deferring the creation of the autocommand because nvim_win_set_cursor
    -- triggers CursorMoved
    vim.defer_fn(create_autocmd, 500)
end

local opts = { noremap=true, silent=true }

vim.keymap.set("n", "<space>e",  open_float, opts)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

-- Requires Neovim 0.7.0+
api.nvim_create_user_command("DiagnosticSetLocationList",
    vim.diagnostic.setloclist, { nargs = 0 })
