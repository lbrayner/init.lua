local lspcommon = require "lspcommon"

require "lspconfig".tsserver.setup {
    autostart = false,
    on_attach = lspcommon.on_attach,
}
