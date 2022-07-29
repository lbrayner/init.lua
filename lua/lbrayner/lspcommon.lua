local keymap = require("lbrayner.keymap")
local nnoremap = keymap.nnoremap
local api = vim.api

local function truncate(bufnr, winid, message, lnum)
    local line = api.nvim_buf_get_lines(bufnr, lnum, lnum+1, true)[1]
    local line_len = string.len(line)
    local winwidth = api.nvim_win_get_width(winid) - 2 - 3 -- sign & column number
    local mess_len = string.len(message)
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

-- From nvim-lspconfig
-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

    -- Commands
    vim.api.nvim_buf_create_user_command(bufnr, "LspRename", function(command)
        local name = command.args
        if name and name ~= "" then
            return vim.lsp.buf.rename(name)
        end
        vim.lsp.buf.rename()
    end, { nargs="?" })

    vim.api.nvim_buf_create_user_command(bufnr, "LspFormat", function()
        vim.lsp.buf.format { async=true }
    end, { nargs=0 })
    vim.api.nvim_buf_create_user_command(bufnr, "LspWorkspaceFolders", function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, { nargs=0 })

    -- Mappings
    local bufopts = { silent=true, buffer=bufnr }
    nnoremap("gD", vim.lsp.buf.declaration, bufopts)
    nnoremap("gd", vim.lsp.buf.definition, bufopts)
    nnoremap("K", vim.lsp.buf.hover, bufopts)
    nnoremap("gi", vim.lsp.buf.implementation, bufopts)
    -- TODO nnoremap("<C-k>", vim.lsp.buf.signature_help, bufopts)
    nnoremap("<space>D", vim.lsp.buf.type_definition, bufopts)
    nnoremap("<F11>", vim.lsp.buf.code_action, bufopts)
    nnoremap("gr", vim.lsp.buf.references, bufopts)

    -- Autocmds
    local augroup = api.nvim_create_augroup("trunc_virt_text_" .. bufnr, { clear=true })
    api.nvim_create_autocmd({ "WinEnter" }, {
        buffer = bufnr,
        group = augroup,
        callback = trunc_virt_text,
    })
end

return {
    on_attach = on_attach,
}
