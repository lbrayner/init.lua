-- vim: fdm=marker

local M = {}

local offset_encoding = "utf-16"
local SymbolKind = vim.lsp.protocol.SymbolKind

local maximum_resolve_depth = 10

local function with_jdtls(fn) -- {{{
  local bufnr = vim.api.nvim_get_current_buf()

  local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "jdtls" })
  local _, client = next(clients)

  -- From nvim-jdtls
  if not client then
    vim.notify("No LSP client with name `jdtls` available", vim.log.levels.WARN)
    return
  end

  fn(client, bufnr)
end -- }}}

function M.java_go_to_top_level_declaration()
  with_jdtls(function(client, bufnr)
    require("lbrayner.lsp").document_symbol(client, function(result, ctx)
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
        uri = ctx.params.textDocument.uri, range = top_level_symbols[1].selectionRange
      }, offset_encoding)
    end, bufnr)
  end)
end

function M.java_is_test_file(cb)
  assert(type(cb) == "function", "'cb' must be a function")

  -- From jdtls.util.with_classpaths
  local bufnr = vim.api.nvim_get_current_buf()
  local uri = vim.uri_from_bufnr(bufnr)

  local is_test_file_cmd = {
    command = "java.project.isTestFile",
    arguments = { uri }
  }

  require("jdtls.util").execute_command(is_test_file_cmd, function(err, result, ctx)
    assert(not err, vim.inspect(err))
    cb(result, ctx)
  end)
end

function M.java_main_symbols(cb)
  assert(type(cb) == "function", "'cb' must be a function")

  with_jdtls(function(client, bufnr)
    require("lbrayner.lsp").document_symbol(client, function(result, ctx)
      if vim.tbl_isempty(result) then
        vim.notify("Get main symbols: no document symbols found", vim.log.levels.ERROR)
        return
      end

      local mains = vim.iter(result):filter(
        function(s)
          return s.kind == SymbolKind.Class and s.children and not vim.tbl_isempty(s.children)
        end
      ):map(
        function(s) return s.children end
      ):flatten():filter(
        function(s)
          return s.kind == SymbolKind.Method and s.detail == " : void" and s.name == "main(String[])"
        end
      ):totable()

      cb(mains, ctx)
    end, bufnr)
  end)
end

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

    local parents = result.parents

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
        -- Symbol at point is a SymbolKind.Method
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

return M
