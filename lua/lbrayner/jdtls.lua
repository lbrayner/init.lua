local M = {}

function M.create_user_command()
  require("lbrayner.jdtls._command")
end

function M.get_config()
  local capabilities = vim.tbl_deep_extend("keep", {
    textDocument = {
      declaration = {
        dynamicRegistration = true,
      },
    },
  }, vim.lsp.protocol.make_client_capabilities())

  local java_debug_jar_pattern = vim.fs.joinpath(vim.fn.stdpath("data"),
    "java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar")
  local vscode_java_test_jar_pattern = vim.fs.joinpath(vim.fn.stdpath("data"), "vscode-java-test/server/*.jar")

  return {
    capabilities = capabilities,
    cmd = require("lspconfig.configs.jdtls").default_config.cmd,
    init_options = {
      bundles = (function()
        local bundles = {}

        local java_debug_jars = vim.fn.glob(java_debug_jar_pattern, 1, 1)
        if vim.tbl_count(java_debug_jars) == 1 then
          vim.list_extend(bundles, java_debug_jars)
        end

        local vscode_java_test_jars = vim.tbl_filter(function(jar)
          -- https://github.com/eclipse-jdtls/eclipse.jdt.ls/issues/2761#issuecomment-1638311201.
          -- Not all jars in vscode-java-test/server should be passed in the bundles setting.
          return not vim.endswith(jar, "com.microsoft.java.test.runner-jar-with-dependencies.jar") and
          not vim.endswith(jar, "jacocoagent.jar")
        end, vim.fn.glob(vscode_java_test_jar_pattern, 1, 1))

        vim.list_extend(bundles, vscode_java_test_jars)

        if not vim.tbl_isempty(bundles) then
          return bundles
        end
      end)(),
    },
    root_dir = require("jdtls.setup").find_root({".git", "mvnw", "gradlew"}),
    settings = {
      java = {
        settings = {
          url = (function()
            local prefs = vim.fs.normalize("~/.local/share/nvim/eclipse/settings.prefs")
            if vim.uv.fs_stat(prefs) then
              return prefs
            end
          end)(),
        }
      }
    },
  }
end

M.operations = require("lbrayner").get_proxy_table_for_module("lbrayner.jdtls._operations")

function M.java_go_to_top_level_declaration()
  M.operations.java_go_to_top_level_declaration()
end

function M.java_type_hierarchy(opts)
  M.operations.java_type_hierarchy(opts)
end

function M.setup(config)
  local jdtls_setup = vim.api.nvim_create_augroup("jdtls_setup", { clear = true })

  vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    group = jdtls_setup,
    pattern = "*.java",
    desc = "New Java buffers attach to JDT Language Server",
    callback = function(args)
      local bufnr = args.buf

      if not vim.startswith(vim.uri_from_bufnr(bufnr), "file://") then
        -- Don't attach to buffers such as Fugitive objects
        return
      end

      require("jdtls").start_or_attach(config)
    end,
  })

  vim.api.nvim_create_autocmd("BufReadCmd", {
    group = jdtls_setup,
    pattern = { "jdt://*", "*.class" },
    desc = "Handle jdt:// URIs and classfiles",
    callback = function(args)
      require("jdtls").start_or_attach(config)
      require("jdtls").open_classfile(args.match)
    end,
  })

  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_get_current_buf() ~= bufnr and
      vim.api.nvim_buf_is_loaded(bufnr) and
      vim.bo[bufnr].ft == "java" and
      vim.startswith(vim.uri_from_bufnr(bufnr), "file://") and
      (not client or not vim.lsp.buf_is_attached(bufnr, client.id)) then
      vim.api.nvim_create_autocmd("BufEnter", {
        group = jdtls_setup,
        buffer = bufnr,
        desc = "This Java buffer will attach to JDT Language Server once focused",
        once = true,
        callback = function()
          require("jdtls").start_or_attach(config)
        end,
      })
    end
  end

  vim.api.nvim_create_autocmd("LspAttach", {
    group = jdtls_setup,
    pattern = { "*.java", "jdt://*", "*.class" },
    desc = "JDT Language Server buffer setup",
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)

      if client.name ~= "jdtls" then
        return
      end

      local bufnr = args.buf
      local bufname = args.match

      local uri = vim.uri_from_bufnr(bufnr)
      if not vim.startswith(uri, "file://") and not vim.startswith(uri, "jdt://") then
        -- Don't attach to buffers such as Fugitive objects
        return
      end

      -- Mappings
      local bufopts = { buffer = bufnr }
      vim.keymap.set("n", "gC", M.java_go_to_top_level_declaration, bufopts)
      vim.keymap.set("n", "gY", M.java_type_hierarchy, bufopts)
    end,
  })

  require("jdtls").start_or_attach(config)
end

return M
