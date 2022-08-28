vim.cmd.packadd "nvim-jdtls"

local lspconfig = require "lspconfig.server_configurations.jdtls"

local function on_attach(client, bufnr)
    require "lbrayner.lspcommon".on_attach(client, bufnr)

    -- Override mappings
    local nnoremap = require("lbrayner.keymap").nnoremap
    local bufopts = { buffer=bufnr }
    -- Go to class declaration
    nnoremap("gD", function()
        vim.api.nvim_win_set_cursor(0, {1, 0})
        if vim.fn.search("^public\\s\\+class\\s\\+\\zs" ..
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

return {
    get_config = function()
        return config
    end,
}
