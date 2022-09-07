vim.cmd.packadd "nvim-lspconfig"

local api = vim.api
local keymap = require("lbrayner.keymap")
local nnoremap = keymap.nnoremap

-- From nvim-lspconfig
-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local function on_attach(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    -- Some filetype plugins define omnifunc and $VIMRUNTIME/lua/vim/lsp.lua
    -- respects that, so we override it.
    api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

    -- Commands
    api.nvim_buf_create_user_command(bufnr, "LspRename", function(command)
        local name = command.args
        if name and name ~= "" then
            return vim.lsp.buf.rename(name)
        end
        vim.lsp.buf.rename()
    end, { nargs="?" })

    api.nvim_buf_create_user_command(bufnr, "LspFormat", function()
        vim.lsp.buf.format { async=true }
    end, { nargs=0 })
    api.nvim_buf_create_user_command(bufnr, "LspWorkspaceFolders", function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, { nargs=0 })

    -- Mappings
    local bufopts = { buffer=bufnr }
    nnoremap("gD", vim.lsp.buf.declaration, bufopts)
    nnoremap("gd", vim.lsp.buf.definition, bufopts)
    nnoremap("K", vim.lsp.buf.hover, bufopts)
    nnoremap("gi", vim.lsp.buf.implementation, bufopts)
    nnoremap("gK", vim.lsp.buf.signature_help, bufopts)
    nnoremap("<Space>D", vim.lsp.buf.type_definition, bufopts)
    nnoremap("<F11>", vim.lsp.buf.code_action, bufopts)
    nnoremap("gr", vim.lsp.buf.references, bufopts)

    -- Custom statusline
    vim.b[bufnr].Statusline_custom_rightline = '%9*' .. client.name .. '%* '
    vim.b[bufnr].Statusline_custom_mod_rightline = '%9*' .. client.name .. '%* '
end

return {
    on_attach = on_attach,
}
