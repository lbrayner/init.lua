local lspconfig = require("lspconfig.server_configurations.jdtls")

local M = {}

function M.get_config()
  return {
    capabilities = {
      textDocument = {
        completion = {
          completionItem = {
            snippetSupport = true,
          },
        },
        declaration = {
          dynamicRegistration = true,
          linkSupport = true
        },
      },
    },
    cmd = lspconfig.default_config.cmd,
    root_dir = require("jdtls.setup").find_root({".git", "mvnw", "gradlew"}),
    settings = {
      java = {
        settings = {
          url = (function()
            local prefs = vim.fn.fnamemodify("~/.config/nvim/config/jdtls/settings.prefs", ":p")
            if vim.fn.filereadable(prefs) == 1 then
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

  -- From nvim-jdtls
  local clients = vim.lsp.get_active_clients({ bufnr = bufnr, name = "jdtls" })
  local _, client = next(clients)
  if not client then
    vim.notify("No LSP client with name `jdtls` available", vim.log.levels.WARN)
    return
  end

  local params = { textDocument = vim.lsp.util.make_text_document_params(bufnr) }

  client.request("textDocument/documentSymbol", params, function(err, result, ctx)
    assert(not err, vim.inspect(err))

    local top_level_symbols = vim.tbl_filter(function(symbol)
      return vim.tbl_contains({
        SymbolKind.Class,
        SymbolKind.Enum,
        SymbolKind.Interface
      }, symbol.kind)
    end, result)

    if #top_level_symbols > 1 then
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

    vim.lsp.util.jump_to_location({
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

    if #parents > 0 and depth > maximum_resolve_depth then
      vim.notify(string.format("Type hierarchy: maximum resolve depth is %d.", maximum_resolve_depth),
        vim.log.levels.WARN)
    elseif #parents > 0 then
      local parent_classes = vim.tbl_filter(function(parent)
        return parent.kind == SymbolKind.Class
      end, parents)

      assert(#parent_classes <= 1, "Type hierarchy: more than one parent class")

      local parent = parent_classes[1]
      if not parent then
        assert(#parents == 1, string.format("Type hierarchy: could not determine parent with result %s",
          vim.inspect(result)))
        -- Symbol at point is a SymbolKind.Method, parent is a SymbolKind.Interface
        parent = parents[1]
      end

      for _, parent in ipairs(parents) do
        table.insert(hierarchy, parent)
      end
      return require("jdtls.util").execute_command(resolve_command(parent), resolve_handler)
    end

    if #hierarchy > 0 then
      local root = hierarchy[#hierarchy]
      if root.detail.."."..root.name == "java.lang.Object" then
        table.remove(hierarchy) -- Pop the top
      end
    end

    if #hierarchy == 0 then return print("Type hierarchy: no results.") end

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
      return opts.on_list({ title = title, items = items, context = ctx })
    end

    if #locations == 1  then
      return vim.lsp.util.jump_to_location(locations[1], offset_encoding, opts.reuse_win)
    end

    vim.fn.setqflist({}, " ", { title = title, items = items, context = ctx })
    vim.api.nvim_command("botright copen")
  end

  opts = opts or {}
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
      return vim.notify("Type hierarchy: openTypeHierarchy returned no results",
        vim.log.levels.ERROR)
    end
    open_type_hierarchy = result
    require("jdtls.util").execute_command(resolve_command(result), resolve_handler)
  end)
end

return M
