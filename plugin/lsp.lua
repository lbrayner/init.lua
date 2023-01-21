vim.cmd.packadd "nvim-lspconfig"
vim.cmd.packadd "typescript.nvim"

-- Typescript, Javascript
require("typescript").setup({
    server = {
        autostart = false,
    },
})

-- Python
require("lspconfig").pyright.setup {
    autostart = false,
}

local quickfix_diagnostics_opts = {}
local lsp_setqflist

-- From nvim-lspconfig
-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local function on_attach(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    -- Some filetype plugins define omnifunc and $VIMRUNTIME/lua/vim/lsp.lua
    -- respects that, so we override it.
    vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

    -- Mappings
    local bufopts = { buffer=bufnr }
    vim.keymap.set("n","gD", function()
        vim.lsp.buf.declaration({ reuse_win=true })
    end, bufopts)
    vim.keymap.set("n","gd", function()
        vim.lsp.buf.definition({ reuse_win=true })
    end, bufopts)
    vim.keymap.set("n","K", vim.lsp.buf.hover, bufopts)
    vim.keymap.set("n","gi", vim.lsp.buf.implementation, bufopts)
    vim.keymap.set("n","gK", vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set("n","<Space>D", vim.lsp.buf.type_definition, bufopts)
    vim.keymap.set("n","<F11>", vim.lsp.buf.code_action, bufopts)
    vim.keymap.set("n","gr", vim.lsp.buf.references, bufopts)

    -- Commands
    vim.api.nvim_buf_create_user_command(bufnr, "LspRename", function(command)
        local name = command.args
        if name and name ~= "" then
            return vim.lsp.buf.rename(name)
        end
        vim.lsp.buf.rename()
    end, { nargs="?" })

    vim.api.nvim_buf_create_user_command(bufnr, "LspDeclaration", vim.lsp.buf.declaration, { nargs=0 })
    vim.api.nvim_buf_create_user_command(bufnr, "LspDefinition", vim.lsp.buf.definition, { nargs=0 })
    vim.api.nvim_buf_create_user_command(bufnr, "LspFormat", function()
        vim.lsp.buf.format { async=true }
    end, { nargs=0 })
    vim.api.nvim_buf_create_user_command(bufnr, "LspWorkspaceFolders", function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, { nargs=0 })
    vim.api.nvim_buf_create_user_command(bufnr, "LspDiagnosticQuickFixAll", function(_command)
        lsp_setqflist({}, bufnr)
    end, { nargs=0 })
    vim.api.nvim_buf_create_user_command(bufnr, "LspDiagnosticQuickFixError", function(_command)
        lsp_setqflist({ severity=vim.diagnostic.severity.ERROR }, bufnr)
    end, { nargs=0 })
    vim.api.nvim_buf_create_user_command(bufnr, "LspDiagnosticQuickFixWarn", function(_command)
        lsp_setqflist({ severity={ min=vim.diagnostic.severity.WARN } }, bufnr)
    end, { nargs=0 })

    -- Custom statusline
    vim.b[bufnr].Statusline_custom_rightline = '%9*' .. client.name .. '%* '
    vim.b[bufnr].Statusline_custom_mod_rightline = '%9*' .. client.name .. '%* '
    vim.cmd "silent! doautocmd <nomodeline> User CustomStatusline"

    -- Client specific settings

    if client.name == "jdtls" then
        -- TODO disabling semantic highlighting for now
        client.server_capabilities.semanticTokensProvider = nil
        -- Go to class declaration
        vim.keymap.set("n","gD", function()
            vim.api.nvim_win_set_cursor(0, {1, 0})
            if vim.fn.search(
                "\\v^public\\s+%(abstract\\s+)?%(final\\s+)?%(class|enum|interface)\\s+\\zs" ..
                vim.fn.expand("%:t:r")) > 0 then
                vim.cmd "normal! zz"
            end
        end, bufopts)
    end
end

local lsp_setup = vim.api.nvim_create_augroup("lsp_setup", { clear=true })

vim.api.nvim_create_autocmd("LspAttach", {
    group = lsp_setup,
    desc = "LSP buffer setup",
    callback = function(args)
        local bufnr = args.buf
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        on_attach(client, bufnr)
    end,
})

vim.api.nvim_create_autocmd("LspDetach", {
    group = lsp_setup,
    desc = "Undo LSP buffer setup",
    callback = function(args)
        local bufnr = args.buf
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not vim.lsp.buf_is_attached(bufnr, client.id) then
            return
        end

        -- Restoring the statusline
        vim.b[bufnr].Statusline_custom_rightline = nil
        vim.b[bufnr].Statusline_custom_mod_rightline = nil

        -- Deleting user commands
        for _, command in ipairs({
            "LspDeclaration",
            "LspDefinition",
            "LspFormat",
            "LspWorkspaceFolders",
            "LspDiagnosticQuickFixAll",
            "LspDiagnosticQuickFixError",
            "LspDiagnosticQuickFixWarn",
        }) do
            vim.api.nvim_buf_del_user_command(bufnr, command)
        end
    end,
})

vim.api.nvim_create_autocmd({ "DiagnosticChanged" }, {
    group = lsp_setup,
    callback = function(_args)
        if vim.startswith(vim.fn.getqflist({ title=true }).title, "LSP Diagnostics") then
            vim.diagnostic.setqflist(vim.tbl_extend("error", quickfix_diagnostics_opts, {
                open=false }))
        end
    end,
})

lsp_setqflist = function(opts, bufnr)
    local active_clients = vim.lsp.get_active_clients({bufnr=bufnr})
    if #active_clients ~= 1 then
        quickfix_diagnostics_opts = vim.tbl_extend("error", opts, {
            title = "LSP Diagnostics"
        })
        return vim.diagnostic.setqflist(quickfix_diagnostics_opts)
    end
    local active_client = active_clients[1]
    quickfix_diagnostics_opts = vim.tbl_extend("error", opts, {
        namespace = vim.lsp.diagnostic.get_namespace(active_client.id),
        title = "LSP Diagnostics: " .. active_client.name
    })
    vim.diagnostic.setqflist(quickfix_diagnostics_opts)
end

local lspconfig_custom = vim.api.nvim_create_augroup("lspconfig_custom", { clear=true })

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    group = lspconfig_custom,
    desc = "New buffers attach to LS managed by lspconfig even when autostart is false",
    callback = function(args)
        for _, client in ipairs(vim.lsp.get_active_clients()) do
            if vim.tbl_get(client, "config", "workspace_folders") then
                local names = vim.tbl_map(function (workspace_folder)
                    return workspace_folder.name
                end, client.config.workspace_folders)
                for _, name in ipairs(names) do
                    if vim.startswith(vim.api.nvim_buf_get_name(args.buf), name) then
                        if vim.fn.exists("#lspconfig#BufReadPost#" .. name .. "/*") == 1 then
                            return vim.cmd("doautocmd lspconfig BufReadPost " .. name .. "/*")
                        end
                    end
                end
            end
        end
    end,
})
