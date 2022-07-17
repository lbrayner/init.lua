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
    local float_bufnr, _ = vim.diagnostic.open_float({ close_events={} })
    api.nvim_command(vim.fn.bufwinnr(float_bufnr) .. "wincmd w")
end

local opts = { noremap=true, silent=true }

vim.keymap.set("n", "<space>e",  open_float, opts)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

-- Requires Neovim 0.7.0+
api.nvim_create_user_command("DiagnosticSetLocationList",
    vim.diagnostic.setloclist, { nargs = 0 })
