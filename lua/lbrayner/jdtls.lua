vim.cmd.packadd "nvim-jdtls"

local lspconfig = require "lspconfig.server_configurations.jdtls"

local function on_attach(client, bufnr)
    -- TODO disabling semantic highlighting for now
    client.server_capabilities.semanticTokensProvider = nil
    require "lbrayner.lspcommon".on_attach(client, bufnr)

    -- Override mappings
    local nnoremap = require("lbrayner.keymap").nnoremap
    local bufopts = { buffer=bufnr }
    -- Go to class declaration
    nnoremap("gD", function()
        vim.api.nvim_win_set_cursor(0, {1, 0})
        if vim.fn.search(
            "\\v^public\\s+%(abstract\\s+)?%(final\\s+)?%(class|enum|interface)\\s+\\zs" ..
            vim.fn.expand("%:t:r")) > 0 then
            vim.cmd "normal! zz"
        end
    end, bufopts)
end

local config = {
    cmd = lspconfig.default_config.cmd,
    on_attach = on_attach,
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
