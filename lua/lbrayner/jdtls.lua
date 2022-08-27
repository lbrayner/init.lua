vim.cmd.packadd "nvim-jdtls"

local lspcommon = require "lbrayner.lspcommon"
local lspconfig = require "lspconfig.server_configurations.jdtls"

local config = {
    -- The command that starts the language server
    -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
    cmd = lspconfig.default_config.cmd,
    on_attach = lspcommon.on_attach,
    root_dir = require('jdtls.setup').find_root({'.git', 'mvnw', 'gradlew'}),
}

return {
    get_config = function()
        return config
    end,
}
