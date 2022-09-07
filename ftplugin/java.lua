local nvim_buf_create_user_command = vim.api.nvim_buf_create_user_command
local nvim_buf_del_user_command = vim.api.nvim_buf_del_user_command

local function jdtls_delete_commands(bufnr)
    nvim_buf_del_user_command(bufnr, "JdtCompile")
    nvim_buf_del_user_command(bufnr, "JdtSetRuntime")
    nvim_buf_del_user_command(bufnr, "JdtUpdateConfig")
    nvim_buf_del_user_command(bufnr, "JdtJol")
    nvim_buf_del_user_command(bufnr, "JdtBytecode")
    nvim_buf_del_user_command(bufnr, "JdtJshell")
    nvim_buf_del_user_command(bufnr, "JdtStop")
end

local function jdtls_create_commands(bufnr)
    nvim_buf_create_user_command(bufnr, "JdtCompile", function(command)
        require("jdtls").compile(command.fargs)
    end, { complete="custom,v:lua.require'jdtls'._complete_compile", nargs="?" })
    nvim_buf_create_user_command(bufnr, "JdtSetRuntime", function(command)
        require("jdtls").set_runtime(command.fargs)
    end, { complete="custom,v:lua.require'jdtls'._complete_set_runtime", nargs="?" })
    nvim_buf_create_user_command(bufnr, "JdtUpdateConfig", function(_command)
        require("jdtls").update_project_config()
    end, { nargs=0 })
    nvim_buf_create_user_command(bufnr, "JdtJol", require("jdtls").jol, { nargs=0 })
    nvim_buf_create_user_command(bufnr, "JdtBytecode", require("jdtls").javap, { nargs=0 })
    nvim_buf_create_user_command(bufnr, "JdtJshell", require("jdtls").jshell, { nargs=0 })
    nvim_buf_create_user_command(bufnr, "JdtStop", function(_command)
        vim.lsp.stop_client(vim.lsp.get_active_clients({ name="jdt.ls" }))
    end, { nargs=0 })
end

nvim_buf_create_user_command(0, "JdtlsStart", function(_command)
    local config = require("lbrayner.jdtls").get_config()

    if vim.lsp.get_active_clients({ name="jdt.ls" })[1] then
        return require("jdtls").start_or_attach(config)
    end

    local jdtls_setup = vim.api.nvim_create_augroup("jdtls_setup", { clear=true })

    vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
        group = jdtls_setup,
        pattern = config.root_dir .. "/*.java",
        desc = "New Java buffers attach to jdt.ls",
        callback = function()
            require("jdtls").start_or_attach(config)
        end,
    })

    local is_descendant = require("lspconfig.util").path.is_descendant

    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[bufnr].ft == "java" then
            if is_descendant(config.root_dir, vim.api.nvim_buf_get_name(bufnr)) then
                vim.api.nvim_create_autocmd({ "WinEnter" }, {
                    group = jdtls_setup,
                    buffer = bufnr,
                    desc = "This Java buffer will attach to jdt.ls once focused",
                    callback = function()
                        require("jdtls").start_or_attach(config)
                        return true -- Delete the autocmd
                    end,
                })
            end
        end
    end

    vim.api.nvim_create_autocmd("LspAttach", {
        group = jdtls_setup,
        pattern = config.root_dir .. "/*.java",
        desc = "jdt.ls buffer setup",
        callback = function(args)
            -- Custom statusline
            vim.b.Statusline_custom_leftline = '%<%{expand("%:t:r")} %{statusline#StatusFlag()}'
            vim.b.Statusline_custom_mod_leftline = '%<%1*%{expand("%:t:r")}' ..
            ' %{statusline#StatusFlag()}%*'

            -- Setup buffer local commands
            jdtls_create_commands(args.buf)
        end,
    })

    vim.api.nvim_create_autocmd("LspDetach", {
        group = jdtls_setup,
        pattern = config.root_dir .. "/*.java",
        desc = "Undo jdt.ls buffer setup",
        callback = function(args)
            -- Undo custom statusline
            vim.b.Statusline_custom_leftline = nil
            vim.b.Statusline_custom_mod_leftline = nil
            vim.b.Statusline_custom_rightline = nil
            vim.b.Statusline_custom_mod_rightline = nil

            -- Delete buffer local commands
            jdtls_delete_commands(args.buf)
        end,
    })

    require("jdtls").start_or_attach(config)
end, { desc="Start jdt.ls and setup automatic attach, local buffer configuration", nargs=0 })
