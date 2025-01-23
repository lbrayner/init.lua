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
      vim.uri_from_bufnr(bufnr),
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

function M.drag_backward()
  request_custom_text_document_edit("drag-backward")
end

function M.drag_forward()
  request_custom_text_document_edit("drag-forward")
end

function M.forward_barf()
  request_custom_text_document_edit("forward-barf")
end

function M.forward_slurp()
  request_custom_text_document_edit("forward-slurp")
end

local clojure_lsp_setup = vim.api.nvim_create_augroup("clojure_lsp_setup", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
  group = clojure_lsp_setup,
  pattern = { "*.clj", "*.edn" },
  desc = "clojure-lsp buffer setup",
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    if client.name ~= "clojure_lsp" then
      return
    end

    local bufnr = args.buf

    -- Mappings
    local bufopts = { buffer = bufnr }
    vim.keymap.set("i", "<M-Left>",  M.drag_backward,  bufopts)
    vim.keymap.set("i", "<M-Right>", M.drag_forward,   bufopts)
    vim.keymap.set("i", "<S-Right>", M.backward_barf,  bufopts)
    vim.keymap.set("i", "<S-Left>",  M.forward_barf,   bufopts)
    vim.keymap.set("i", "<S-Up>",    M.backward_slurp, bufopts)
    vim.keymap.set("i", "<S-Down>",  M.forward_slurp,  bufopts)
  end,
})

return M
