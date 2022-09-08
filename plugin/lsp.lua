local lspcommon = require "lbrayner.lspcommon"
local lspconfig = require "lspconfig"

local lsp_setup = vim.api.nvim_create_augroup("lsp_setup", { clear=true })

vim.api.nvim_create_autocmd("LspDetach", {
    group = lsp_setup,
    desc = "Undo custom statusline",
    callback = function(args)
        -- TODO from the documentation: doesn't work, a bug
        -- local client = vim.lsp.get_client_by_id(args.data.client_id)
        -- if not string.find(vim.b[args.buf].Statusline_custom_rightline, client.name) then
        --     return
        -- end
        if not vim.b[args.buf].LSP_Custom_Statusline then
            return
        end
        vim.b[args.buf].Statusline_custom_rightline = nil
        vim.b[args.buf].Statusline_custom_mod_rightline = nil
        vim.b[args.buf].LSP_Custom_Statusline = nil
    end,
})

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
