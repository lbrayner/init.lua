vim.api.nvim_buf_create_user_command(0, "JdtlsStart", function(_command)
    local config = require("lbrayner.jdtls").get_config()

    if vim.lsp.get_active_clients({ name="jdt.ls" })[1] then
        return require("jdtls").start_or_attach(config)
    end

    local jdtls_start = vim.api.nvim_create_augroup("jdtls_start", { clear=true })

    vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
        group = jdtls_start,
        pattern = config.root_dir .. "/*.java",
        callback = function()
            require("jdtls").start_or_attach(config)
        end,
    })

    local is_descendant = require("lspconfig.util").path.is_descendant

    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo.ft == "java" then
            if is_descendant(config.root_dir, vim.api.nvim_buf_get_name(bufnr)) then
                vim.api.nvim_create_autocmd({ "WinEnter" }, {
                    group = jdtls_start,
                    buffer = bufnr,
                    callback = function()
                        require("jdtls").start_or_attach(config)
                        return true -- Delete the autocmd
                    end,
                })
            end
        end
    end

    require("jdtls").start_or_attach(config)
end, { nargs=0 })
