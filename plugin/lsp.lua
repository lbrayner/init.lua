local lspcommon = require "lbrayner.lspcommon"
local api = vim.api

local function truncate(bufnr, winid, message, lnum)
    if string.len(message) == 0 then
        return message
    end
    local line = api.nvim_buf_get_lines(bufnr, lnum, lnum+1, true)[1]
    local line_len = string.len(line)
    local winwidth = api.nvim_win_get_width(winid) - 2 - 3 -- sign & column number
    local mess_len = string.len(message)
    -- TODO debug
    print(string.format("bufnr %s lnum %s line_len %s mess_len %s winwidth %s",
        bufnr, lnum, line_len, mess_len, winwidth))
    if line_len + 1 + mess_len > winwidth then
        return ""
    end
    return message
end

local function trunc_virt_text(args)
    local bufnr = args.buf
    local winid = vim.fn.bufwinid(bufnr)
    if winid < 0 then
        return
    end
    local clients = vim.lsp.get_active_clients({ bufnr=bufnr })
    for _, client in ipairs(clients) do
        local namespace = vim.lsp.diagnostic.get_namespace(client.id)
        local metadata = vim.diagnostic.get_namespace(namespace)
        if metadata.user_data and metadata.user_data.virt_text_ns then
            local virt_text_ns = metadata.user_data.virt_text_ns
            local extmarks = api.nvim_buf_get_extmarks(bufnr, virt_text_ns, 0, -1, {
                details=true })
            for _, extmark in ipairs(extmarks) do
                local id = extmark[1]
                local lnum = extmark[2]
                local col = extmark[3]
                local details = extmark[4]
                for _, virt_text_pair in ipairs(details.virt_text) do
                    virt_text_pair[1] = truncate(bufnr, winid, virt_text_pair[1], lnum)
                end
                details.id = id
                api.nvim_buf_set_extmark(bufnr, virt_text_ns, lnum, col, details)
            end
        end
    end
end

-- Autocmds
local augroup = api.nvim_create_augroup("trunc_virt_text", { clear=true })
api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
    group = augroup,
    callback = trunc_virt_text,
})

require "lspconfig".tsserver.setup {
    autostart = false,
    on_attach = lspcommon.on_attach,
}
