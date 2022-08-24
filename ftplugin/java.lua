vim.api.nvim_buf_create_user_command(0, "JdtlsStart", function(_command)
    local config = require("lbrayner.jdtls").get_config()

    if vim.lsp.get_active_clients({ name="jdt.ls" })[1] then
        return require("jdtls").start_or_attach(config)
    end

    local jdtls_start = vim.api.nvim_create_augroup("jdtls_start", { clear=true })

    -- TODO check lsp root/workspace dir
    vim.api.nvim_create_autocmd({ "FileType" }, {
        group = jdtls_start,
        pattern = "java",
        callback = function()
            require("jdtls").start_or_attach(config)
        end,
    })

    -- TODO check lsp root/workspace dir
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo.ft == "java" then
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

    require("jdtls").start_or_attach(config)
end, { nargs=0 })
