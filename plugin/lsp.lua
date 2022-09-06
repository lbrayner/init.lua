local lspcommon = require "lbrayner.lspcommon"
local lspconfig = require "lspconfig"

-- Typescript, Javascript
lspconfig.tsserver.setup {
    autostart = false,
    on_attach = lspcommon.on_attach,
}

-- Python
local pyright_attach = vim.api.nvim_create_augroup("pyright_attach", { clear=true })

vim.api.nvim_create_autocmd("LspAttach", {
    group = pyright_attach,
    pattern = { "*.py" },
    desc = "Custom statusline for pyright",
    callback = function(args)
        if vim.lsp.get_client_by_id(args.data.client_id).name == "pyright" then
            vim.b[args.buf].Statusline_custom_rightline = '%9*pyright%* '
            vim.b[args.buf].Statusline_custom_mod_rightline = '%9*pyright%* '
        end
    end,
})

lspconfig.pyright.setup {
    autostart = false,
    on_attach = lspcommon.on_attach,
}

vim.api.nvim_create_autocmd("LspDetach", {
    group = pyright_attach,
    desc = "Undo custom statusline",
    callback = function(args)
        vim.b[args.buf].Statusline_custom_rightline = nil
        vim.b[args.buf].Statusline_custom_mod_rightline = nil
    end,
})
