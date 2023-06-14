local lspconfig = require "lspconfig.server_configurations.jdtls"

local M = {}

function M.get_config()
  return {
    cmd = lspconfig.default_config.cmd,
    root_dir = require("jdtls.setup").find_root({".git", "mvnw", "gradlew"}),
    url = (function()
      local prefs = vim.fn.fnamemodify("~/.config/nvim/config/jdtls/settings.prefs", ":p")
      if vim.fn.filereadable(prefs) == 1 then
        return prefs
      end
    end)(),
  }
end

-- Go to top level declaration
function M.java_go_to_top_level_declaration()
  local params = { textDocument = vim.lsp.util.make_text_document_params() }
  vim.lsp.buf_request(0, "textDocument/documentSymbol", params, function(err, result)
    assert(not err, vim.inspect(err))
    local top_level_symbols = vim.tbl_filter(function(symbol)
      -- org.eclipse.lsp4j.SymbolKind.Class(5)
      -- org.eclipse.lsp4j.SymbolKind.Enum(10)
      -- org.eclipse.lsp4j.SymbolKind.Interface(11)
      return symbol.kind == 5 or symbol.kind == 10 or symbol.kind == 11
    end, result)
    assert(#top_level_symbols == 1, "File contains more than one top level symbol declaration")
    vim.lsp.util.jump_to_location({
      uri = params.textDocument.uri, range = top_level_symbols[1].selectionRange
    }, "utf-16")
  end)
end

return M
