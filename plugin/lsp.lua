local lspcommon = require "lbrayner.lspcommon"
local lspconfig = require "lspconfig"

-- Typescript, Javascript
lspconfig.tsserver.setup {
    autostart = false,
    on_attach = lspcommon.on_attach,
}

-- Python
lspconfig.pyright.setup {
    autostart = false,
    on_attach = lspcommon.on_attach,
}

local lsp_setup = vim.api.nvim_create_augroup("lsp_setup", { clear=true })

vim.api.nvim_create_autocmd("LspDetach", {
    group = lsp_setup,
    desc = "Undo custom statusline (lbrayner.lspcommon.on_attach)",
    callback = function(args)
        if not vim.lsp.buf_is_attached(args.buf, args.data.client_id) then
            return
        end
        vim.b[args.buf].Statusline_custom_rightline = nil
        vim.b[args.buf].Statusline_custom_mod_rightline = nil
    end,
})

local set_quickfix_diagnostics_opts = require("lbrayner.diagnostic").set_quickfix_diagnostics_opts

local function lsp_setqflist(opts, bufnr)
    local active_clients = vim.lsp.get_active_clients({bufnr=bufnr})
    if #active_clients ~= 1 then
        return vim.diagnostic.setqflist(set_quickfix_diagnostics_opts(opts))
    end
    local active_client = active_clients[1]
    opts = vim.tbl_extend("error", opts, {
        namespace=vim.lsp.diagnostic.get_namespace(active_client.id) })
    set_quickfix_diagnostics_opts(opts)
    vim.diagnostic.setqflist(opts)
end

vim.api.nvim_create_autocmd("LspAttach", {
    group = lsp_setup,
    desc = "Setup LSP user commands",
    callback = function(args)
        vim.api.nvim_buf_create_user_command(args.buf, "LspQuickFixDiagnosticAll", function(_command)
            lsp_setqflist({}, args.buf)
        end, { nargs=0 })
        vim.api.nvim_buf_create_user_command(args.buf, "LspQuickFixDiagnosticErrors", function(_command)
            quickfix_diagnostics_opts = { severity=vim.diagnostic.severity.ERROR }
            lsp_setqflist({ severity=vim.diagnostic.severity.ERROR }, args.buf)
        end, { nargs=0 })
    end,
})

vim.api.nvim_create_autocmd("LspDetach", {
    group = lsp_setup,
    desc = "Undo LSP user commands",
    callback = function(args)
        vim.api.nvim_buf_del_user_command(args.buf, "LspQuickFixDiagnosticAll")
        vim.api.nvim_buf_del_user_command(args.buf, "LspQuickFixDiagnosticErrors")
    end,
})
