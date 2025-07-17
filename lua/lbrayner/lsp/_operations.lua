local M = {}

local is_test_file = require("lbrayner.lsp").is_test_file
local on_list = require("lbrayner.lsp").on_list

function M.declaration()
  vim.lsp.buf.declaration({ on_list = on_list, reuse_win = true })
end

function M.definition()
  vim.lsp.buf.definition({ on_list = on_list, reuse_win = true })
end

function M.document_symbol(client, cb, bufnr)
  assert(type(cb) == "function", "'cb' must be a function")
  assert(type(bufnr) == "number", "'bufnr' must be a number")
  assert(
    vim.tbl_get(client, "id") and vim.lsp.buf_is_attached(bufnr, client.id),
    "'client' must be of type vim.lsp.Client and 'bufnr' must be attached to it"
  )

  local params = { textDocument = vim.lsp.util.make_text_document_params(bufnr) }

  client:request("textDocument/documentSymbol", params, function(err, result, ctx)
    assert(not err, vim.inspect(err))
    cb(result, ctx)
  end, bufnr)
end

function M.hover()
  vim.lsp.buf.hover({ close_events = require("lbrayner").get_close_events() })
end

-- Documentation is missing reuse_win
function M.implementation()
  vim.lsp.buf.implementation({ on_list = on_list, reuse_win = true })
end

function M.references(config)
  local context = { includeDeclaration = false }

  config = config or {}

  if config.no_tests then
    vim.lsp.buf.references(context, { on_list = function(options)
      options.items = vim.tbl_filter(function(item)
        -- Filter out tests
        return not is_test_file(item.filename)
      end, options.items)
      on_list(options)
    end })
    return
  end

  vim.lsp.buf.references(context, { on_list = on_list })
end

function M.type_definition()
  vim.lsp.buf.type_definition({ on_list = on_list, reuse_win = true })
end

return M
