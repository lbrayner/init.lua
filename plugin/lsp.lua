local lspcommon = require "lbrayner.lspcommon"
local lspconfig = require "lspconfig"

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
