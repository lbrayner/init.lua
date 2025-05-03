---@type table<string, MyCmdSubcommand>
local subcommand_tbl = {}
require("lbrayner.subcommands").create_command_and_subcommands("Jdt", subcommand_tbl, {
  bang = true,
  desc = "JDT Language Server commands",
})

subcommand_tbl.goToTopLevelDeclaration = {
  simple = require("lbrayner.jdtls").java_go_to_top_level_declaration,
}

subcommand_tbl.organizeImports = {
  simple = function()
    require("jdtls").organize_imports()
  end,
}

subcommand_tbl.setupDapMainClassConfigs = {
  simple = function()
    require("jdtls.dap").setup_dap_main_class_configs({
      on_ready = function()
        local success, session = pcall(require, "lbrayner.session.jdtls")

        if not success then
          return
        end

        local dap_configs_on_ready = session.dap_configs_on_ready

        if dap_configs_on_ready and type(dap_configs_on_ready) == "function" then
          dap_configs_on_ready()
        end
      end
  })
  end,
}

subcommand_tbl.start = {
  simple = function(opts)
    local bufnr = vim.api.nvim_get_current_buf()

    if vim.bo[bufnr].filetype ~= "java" then
      vim.notify("JDT Language Server start requires a Java buffer", vim.log.levels.WARN)
      return
    end

    local config
    local success, session = pcall(require, "lbrayner.session.jdtls")

    if success and session.get_config and type(session.get_config) == "function" then
      config = session.get_config()
    else
      config = require("lbrayner.jdtls").get_config()
    end

    local client = vim.lsp.get_clients({ name = "jdtls" })[1]

    if not opts.bang and client then
      require("jdtls").start_or_attach(config)
      return
    end

    require("lbrayner.jdtls").setup(config)
  end,
}

subcommand_tbl.stop = {
  simple = function()
    local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "jdtls" })
    local _, client = next(clients)

    -- From nvim-jdtls
    if not client then
      vim.notify("No LSP client with name `jdtls` available", vim.log.levels.WARN)
      return
    end

    vim.api.nvim_del_augroup_by_name("jdtls_setup")
    vim.lsp.stop_client(client.id)
  end,
}

subcommand_tbl.testClass = {
  simple = require("lbrayner.jdtls").test_class,
}

subcommand_tbl.testNearestMethod = {
  simple = function()
    require("jdtls").test_nearest_method()
  end,
}

subcommand_tbl.typeHierarchy = {
  simple = require("lbrayner.jdtls").java_type_hierarchy,
}

subcommand_tbl.updateProjectConfig = {
  simple = require("jdtls").update_project_config,
}

subcommand_tbl.updateProjectsConfig = {
  complete = { "--all", "--prompt" },
  optional = function(args, complete)
    assert(
      vim.tbl_isempty(args) or #args == 1,
      string.format("Illegal arguments: %s", table.concat(args, " "))
    )

    local _, arg = next(args)

    if not arg then
      require("jdtls").update_projects_config()
      return
    end

    assert(
      vim.list_contains(complete, arg),
      string.format("Illegal arguments: %s", table.concat(args, " "))
    )

    local select_mode = arg:match("--(%a+)")
    require("jdtls").update_projects_config({ select_mode = select_mode })
  end,
}
