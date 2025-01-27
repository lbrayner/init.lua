local lspconfig = require("lspconfig.server_configurations.jdtls")

local M = {}

function M.get_config()
  local capabilities = vim.tbl_deep_extend("keep", {
    textDocument = {
      declaration = {
        dynamicRegistration = true,
        linkSupport = true
      },
    },
  }, require("lbrayner.lsp").default_capabilities())

  local java_debug_jar_pattern = vim.fs.joinpath(vim.fn.stdpath("data"),
    "java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar")
  local vscode_java_test_jar_pattern = vim.fs.joinpath(vim.fn.stdpath("data"), "vscode-java-test/server/*.jar")

  return {
    capabilities = capabilities,
    cmd = lspconfig.default_config.cmd,
    init_options = {
      bundles = (function()
        local bundles = {}

        local java_debug_jars = vim.fn.glob(java_debug_jar_pattern, 1, 1)
        if vim.tbl_count(java_debug_jars) == 1 then
          table.insert(bundles, java_debug_jars[1])
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
            local prefs = vim.fs.normalize("~/.config/nvim/config/jdtls/settings.prefs")
            if vim.uv.fs_stat(prefs) then
              return prefs
            end
          end)(),
        }
      }
    },
  }
end

local offset_encoding = "utf-16"
local SymbolKind = vim.lsp.protocol.SymbolKind

function M.java_go_to_top_level_declaration()
  local bufnr = vim.api.nvim_get_current_buf()

  local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "jdtls" })
  local _, client = next(clients)

  -- From nvim-jdtls
  if not client then
    vim.notify("No LSP client with name `jdtls` available", vim.log.levels.WARN)
    return
  end

  local params = { textDocument = vim.lsp.util.make_text_document_params(bufnr) }

  client.request("textDocument/documentSymbol", params, function(err, result, ctx)
    assert(not err, vim.inspect(err))

    if vim.tbl_isempty(result) then
      vim.notify("Go to top level declaration: no document symbols found", vim.log.levels.ERROR)
      return
    end

    local top_level_symbols = vim.tbl_filter(function(symbol)
      return vim.tbl_contains({
        SymbolKind.Class,
        SymbolKind.Enum,
        SymbolKind.Interface
      }, symbol.kind)
    end, result)

    if vim.tbl_count(top_level_symbols) > 1 then
      -- Removing children
      top_level_symbols = vim.tbl_map(function(symbol)
        symbol.children = nil
        return symbol
      end, top_level_symbols)

      local title = string.format("Top level symbols in %s",
        vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":."))
      local items = vim.lsp.util.symbols_to_items(top_level_symbols, bufnr)

      vim.fn.setqflist({}, " ", { title = title, items = items, context = ctx })
      vim.api.nvim_command("botright copen")
      return
    end

    vim.lsp.util.show_document({
      uri = params.textDocument.uri, range = top_level_symbols[1].selectionRange
    }, offset_encoding)
  end, bufnr)
end

local maximum_resolve_depth = 10

-- Type hierarchy on quickfix list
function M.java_type_hierarchy(opts)
  local function resolve_command(result)
    return {
      command = "java.navigate.resolveTypeHierarchy",
      arguments = {
        vim.fn.json_encode(result), -- toResolve: TypeHierarchyItem
        "1", -- direction: Children(0), Parents(1), Both(2)
        "1", -- resolveDepth
      },
    }
  end

  local hierarchy = {}
  local depth = 0
  local open_type_hierarchy

  local function resolve_handler(err, result, ctx)
    assert(not err, vim.inspect(err))
    depth = depth + 1

    local parents = vim.tbl_filter(function(parent)
      -- Filtering out SymbolKind.Null items
      return parent.kind ~= SymbolKind.Null
    end, result.parents)

    if not vim.tbl_isempty(parents) and depth > maximum_resolve_depth then
      vim.notify(string.format("Type hierarchy: maximum resolve depth is %d.", maximum_resolve_depth),
        vim.log.levels.WARN)
    elseif not vim.tbl_isempty(parents) then
      local parent_classes = vim.tbl_filter(function(parent)
        return parent.kind == SymbolKind.Class
      end, parents)

      assert(vim.tbl_count(parent_classes) <= 1, "Type hierarchy: more than one parent class")

      local parent = parent_classes[1]
      if not parent then
        assert(vim.tbl_count(parents) == 1,
          string.format("Type hierarchy: could not determine parent with result %s",
          vim.inspect(result)))
        -- Symbol at point is a SymbolKind.Method, parent is a SymbolKind.Interface
        parent = parents[1]
      end

      vim.list_extend(hierarchy, parents)

      require("jdtls.util").execute_command(resolve_command(parent), resolve_handler)
      return
    end

    if not vim.tbl_isempty(hierarchy) then
      local root = hierarchy[#hierarchy]
      if root.detail.."."..root.name == "java.lang.Object" then
        table.remove(hierarchy) -- Pop the top
      end
    end

    if vim.tbl_isempty(hierarchy) then
      vim.notify("Type hierarchy: no results.")
      return
    end

    local locations = vim.tbl_map(function(parent)
      return { uri = parent.uri, range = parent.selectionRange }
    end, hierarchy)

    local title = string.format("Type hierarchy: %s.%s", open_type_hierarchy.detail, open_type_hierarchy.name)
    if vim.tbl_get(open_type_hierarchy, "data", "method_name") then
      title = string.format("%s.%s", title, open_type_hierarchy.data.method_name)
    end

    hierarchy = nil
    depth = nil
    open_type_hierarchy = nil

    local items = {}
    for _, location in ipairs(locations) do -- Preserving table order
      table.insert(items, vim.lsp.util.locations_to_items({ location }, offset_encoding)[1])
    end

    if opts.on_list then
      assert(type(opts.on_list) == "function", "on_list is not a function")
      opts.on_list({ title = title, items = items, context = ctx })
      return
    end

    if vim.tbl_count(locations) == 1  then
      vim.lsp.util.show_document(locations[1], offset_encoding, opts.reuse_win)
      return
    end

    vim.fn.setqflist({}, " ", { title = title, items = items, context = ctx })
    vim.api.nvim_command("botright copen")
  end

  opts = opts or {
    on_list = require("lbrayner.lsp").on_list,
    reuse_win = true
  }

  local position = vim.lsp.util.make_position_params(0, offset_encoding)
  local command = {
    command = "java.navigate.openTypeHierarchy",
    arguments = {
      vim.fn.json_encode(position), -- textParams: TextDocumentPositionParams
      "1", -- direction: Children(0), Parents(1), Both(2)
      "0", -- resolveDepth
    },
  }

  require("jdtls.util").execute_command(command, function(err, result)
    assert(not err, vim.inspect(err))
    if not result then
      vim.notify("Type hierarchy: openTypeHierarchy returned no results", vim.log.levels.ERROR)
      return
    end
    open_type_hierarchy = result
    require("jdtls.util").execute_command(resolve_command(result), resolve_handler)
  end)
end

function M.setup(config, opts)
  opts = opts or {}
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

--- from nvim-jdtls
--- Debug the test class in the current buffer
--- @param opts JdtTestOpts|nil
function M.test_class(opts)
  -- nvim-jdtls internal function
  local function get_first_class_lens(lenses)
    for _, lens in pairs(lenses) do
      -- compatibility for versions prior to
      -- https://github.com/microsoft/vscode-java-test/pull/1257
      -- LegacyTestLevel.Class is 3
      if lens.level == 3 then
        return lens
      end
      -- TestLevel.Class is 5
      if lens.testLevel == 5 then
        return lens
      end
    end
  end

  opts = opts or {}
  local context = require("jdtls.dap").experimental.make_context(opts.bufnr)
  require("jdtls.dap").experimental.fetch_lenses(context, function(lenses)
    local lens = get_first_class_lens(lenses)
    if not lens then
      vim.notify("No test class found")
      return
    end
    require("jdtls.dap").experimental.fetch_launch_args(lens, context, function(launch_args)
      local config = require("jdtls.dap").experimental.make_config(lens, launch_args, opts.config_overrides)
      -- Get extra JVM args from environment
      local dap_jvm_args = os.getenv("DAP_JVM_ARGS")

      if dap_jvm_args and dap_jvm_args ~= "" then
        config.vmArgs = config.vmArgs .. " " .. dap_jvm_args
      end

      require("jdtls.dap").experimental.run(lens, config, context, opts)
    end)
  end)
end

return M
