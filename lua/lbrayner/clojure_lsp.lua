local M = {}

local function request_custom_text_document_edit(command)
  local bufnr = vim.api.nvim_get_current_buf()

  -- From nvim-jdtls
  local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "clojure_lsp" })
  local _, client = next(clients)
  if not client then
    vim.notify("No LSP client with name `clojure_lsp` available", vim.log.levels.WARN)
    return
  end

  local start = vim.lsp.util.make_range_params()["range"]["start"]

  client.request("workspace/executeCommand", {
    command = command,
    arguments = {
      vim.uri_from_bufnr(bufnr), -- toResolve: TypeHierarchyItem
      start.line,
      start.character,
    },
  }, function(err, result, ctx)
    assert(not err, vim.inspect(err))
  end, bufnr)
end

function M.backward_barf()
  request_custom_text_document_edit("backward-barf")
end

function M.backward_slurp()
  request_custom_text_document_edit("backward-slurp")
end

function M.forward_barf()
  request_custom_text_document_edit("forward-barf")
end

function M.forward_slurp()
  request_custom_text_document_edit("forward-slurp")
end

return M
