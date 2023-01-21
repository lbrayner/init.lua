vim.cmd.packadd "nvim-jdtls"

local lspconfig = require "lspconfig.server_configurations.jdtls"

local config = {
    cmd = lspconfig.default_config.cmd,
    root_dir = require("jdtls.setup").find_root({".git", "mvnw", "gradlew"}),
}

-- Add this to site local configuration:

-- -- jdtls global settings
-- require("lbrayner.jdtls").get_config().settings = {
--     java = {
--         settings = {
--             url = os.getenv("HOME").."/.config/nvim/config/jdtls/settings.prefs",
--         },
--     },
-- }

return {
    get_config = function()
        return config
    end,
}
