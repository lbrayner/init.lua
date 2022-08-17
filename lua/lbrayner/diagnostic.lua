local function buffer_severity()
    if not (vim.tbl_count(vim.diagnostic.get(0)) > 0) then
        return nil
    end
    for _, level in ipairs(vim.diagnostic.severity) do
        local items =  vim.diagnostic.get(0, { severity = level })
        if vim.tbl_count(items) > 0 then
            return level
        end
    end
end

return {
    buffer_severity = buffer_severity,
}
