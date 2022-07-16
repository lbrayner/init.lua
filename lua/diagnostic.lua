local opts = { noremap=true, silent=true }

local get_line_col = function()
    local pos = vim.fn.getpos(".")
    return {pos[2]-1, pos[3]-1}
end

local open_float = function()
    local prev_pos = vim.diagnostic.get_prev_pos()
    local next_pos = vim.diagnostic.get_next_pos()
    if not prev_pos and not next_pos then
        return vim.diagnostic.open_float()
    end
    local line_col = get_line_col()
    if prev_pos[1] ~= line_col[1] and next_pos[1] ~= line_col[1] then
        return vim.diagnostic.open_float()
    end
    if next_pos[1] == line_col[1] and next_pos[2] > line_col[2] then
        return vim.diagnostic.goto_next()
    end
    if prev_pos[1] == line_col[1] and prev_pos[2] < line_col[2] then
        return vim.diagnostic.goto_prev()
    end
end

vim.keymap.set("n", "<space>e",  open_float, opts)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

-- Requires Neovim 0.7.0+
local api = vim.api
api.nvim_create_user_command("DiagnosticSetLocationList",
    vim.diagnostic.setloclist, { nargs = 0 })
