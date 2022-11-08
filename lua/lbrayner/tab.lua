local function table_find_index_eq(table, value)
    for i, t in ipairs(table) do
        if t == value then
            return i
        end
    end
end

local function tab_close_range(from, to)
    local tabs_to_close = {}
    -- TODO optimize with while
    for i, t in ipairs(vim.api.nvim_list_tabpages()) do
        if i >= from and i <= to then
            table.insert(tabs_to_close, t)
        end
    end
    -- TODO remove
    print(vim.inspect(tabs_to_close))
    local ei = vim.o.eventignore
    -- TODO remove
    print(vim.inspect(ei))
    vim.opt.eventignore:append {"TabClosed"}
    while not vim.tbl_isempty(tabs_to_close) do
        local tab_to_close = table.remove(tabs_to_close, 1)
        local tabnr = table_find_index_eq(vim.api.nvim_list_tabpages(), tab_to_close)
        vim.cmd(tabnr .. "tabclose")
    end
    vim.o.eventignore = ei
    -- TODO remove
    print(vim.inspect(vim.o.eventignore))
end

return {
    tab_close_range = tab_close_range,
}
