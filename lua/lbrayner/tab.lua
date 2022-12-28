local function table_find_index_eq(table, value)
    for i, t in ipairs(table) do
        if t == value then
            return i
        end
    end
end

local function tab_close_range(bang, from, to)
    local tabs_to_close = {}
    local tab = from
    while tab <= #vim.api.nvim_list_tabpages() and tab <= to do
        table.insert(tabs_to_close, vim.api.nvim_list_tabpages()[tab])
        tab = tab + 1
    end
    local ei = vim.o.eventignore
    vim.opt.eventignore:append {"TabClosed"}
    while not vim.tbl_isempty(tabs_to_close) do
        local tab = table.remove(tabs_to_close, 1)
        local tabnr = table_find_index_eq(vim.api.nvim_list_tabpages(), tab)
        vim.cmd(tabnr .. "tabclose" .. bang)
    end
    vim.o.eventignore = ei
end

local function switch_to_window(file)
    for _, w in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(w)
        local name = vim.api.nvim_buf_get_name(buf)
        if vim.fn.fnamemodify(file,":p") == name then
            -- TODO vim.api.nvim_win_call({window}, {fun}) could be useful
            return vim.api.nvim_set_current_win(w)
        end
    end
end

return {
    tab_close_range = tab_close_range,
    switch_to_window = switch_to_window,
}
