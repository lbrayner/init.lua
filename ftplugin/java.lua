local nvim_buf_create_user_command = vim.api.nvim_buf_create_user_command
local nvim_buf_del_user_command = vim.api.nvim_buf_del_user_command

local function jdtls_buffer_undo(bufnr)
    -- Undo custom statusline
    vim.b[bufnr].Statusline_custom_leftline = nil
    vim.b[bufnr].Statusline_custom_mod_leftline = nil

    -- Delete buffer local commands
    nvim_buf_del_user_command(bufnr, "JdtStop")
    nvim_buf_del_user_command(bufnr, "JdtCompile")
    nvim_buf_del_user_command(bufnr, "JdtSetRuntime")
    nvim_buf_del_user_command(bufnr, "JdtUpdateConfig")
    nvim_buf_del_user_command(bufnr, "JdtJol")
    nvim_buf_del_user_command(bufnr, "JdtBytecode")
    nvim_buf_del_user_command(bufnr, "JdtJshell")
    nvim_buf_del_user_command(bufnr, "JdtOrganizeImports")
end

local function jdtls_create_commands(bufnr)
    nvim_buf_create_user_command(bufnr, "JdtStop", function(_command)
        local client = vim.lsp.get_active_clients({ name="jdtls" })[1]
        if not client then
            return
        end
        for _, buf in pairs(vim.lsp.get_buffers_by_client_id(client.id)) do
            jdtls_buffer_undo(buf)
        end
        vim.api.nvim_del_augroup_by_name("jdtls_setup")
        vim.lsp.stop_client(client.id)
    end, { nargs=0 })
    -- The following are commands from the nvim-jdtls README
    nvim_buf_create_user_command(bufnr, "JdtCompile", function(command)
        require("jdtls").compile(command.fargs)
    end, { complete="custom,v:lua.require'jdtls'._complete_compile", nargs="?" })
    nvim_buf_create_user_command(bufnr, "JdtSetRuntime", function(command)
        require("jdtls").set_runtime(command.fargs)
    end, { complete="custom,v:lua.require'jdtls'._complete_set_runtime", nargs="?" })
    nvim_buf_create_user_command(bufnr, "JdtUpdateConfig", require("jdtls").update_project_config, {
        nargs=0 })
    nvim_buf_create_user_command(bufnr, "JdtJol", require("jdtls").jol, { nargs=0 })
    nvim_buf_create_user_command(bufnr, "JdtBytecode", require("jdtls").javap, { nargs=0 })
    nvim_buf_create_user_command(bufnr, "JdtJshell", require("jdtls").jshell, { nargs=0 })
    nvim_buf_create_user_command(bufnr, "JdtOrganizeImports", require("jdtls").organize_imports, {
        nargs=0 })
end

nvim_buf_create_user_command(0, "JdtStart", function(_command)
    local config = require("lbrayner.jdtls").get_config()

    if vim.lsp.get_active_clients({ name="jdtls" })[1] then
        return require("jdtls").start_or_attach(config)
    end

    local jdtls_setup = vim.api.nvim_create_augroup("jdtls_setup", { clear=true })

    vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
        group = jdtls_setup,
        pattern = config.root_dir .. "/*.java",
        desc = "New Java buffers attach to jdtls",
        callback = function()
            require("jdtls").start_or_attach(config)
        end,
    })

    local is_descendant = require("lspconfig.util").path.is_descendant

    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[bufnr].ft == "java" and
            vim.api.nvim_get_current_buf() ~= bufnr and
            is_descendant(config.root_dir, vim.api.nvim_buf_get_name(bufnr)) then
            vim.api.nvim_create_autocmd({ "BufEnter" }, {
                group = jdtls_setup,
                buffer = bufnr,
                desc = "This Java buffer will attach to jdtls once focused",
                once = true,
                callback = function(_args)
                    require("jdtls").start_or_attach(config)
                end,
            })
        end
    end

    vim.api.nvim_create_autocmd("LspAttach", {
        group = jdtls_setup,
        pattern = config.root_dir .. "/*.java",
        desc = "jdtls buffer setup",
        callback = function(args)
            -- Custom statusline
            vim.b[args.buf].Statusline_custom_leftline = '%<%{expand("%:t:r")} ' ..
            '%{statusline#StatusFlag()}'
            vim.b[args.buf].Statusline_custom_mod_leftline = '%<%1*%{expand("%:t:r")}' ..
            ' %{statusline#StatusFlag()}%*'

            -- Setup buffer local commands
            jdtls_create_commands(args.buf)
        end,
    })

    require("jdtls").start_or_attach(config)
end, { desc="Start jdtls and setup automatic attach, local buffer configuration", nargs=0 })
