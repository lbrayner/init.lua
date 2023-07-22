local mappings = require("snippy.mapping")

vim.keymap.set({ "i", "s" }, "<C-Tab>", mappings.next())
-- Overrides delimitMate's <S-Tab> mapping
vim.keymap.set({ "i", "s" }, "<S-Tab>", mappings.previous())
-- TODO analyze the utility of cut_text
-- vim.keymap.set("x", "<Tab>", mappings.cut_text, { remap = true })
-- vim.keymap.set("n", "g<Tab>", mappings.cut_text, { remap = true })

local InsertTextFormat = vim.lsp.protocol.InsertTextFormat
local complete

local lsp_completion = vim.api.nvim_create_augroup("lsp_completion", { clear = true })

vim.api.nvim_create_autocmd("CompleteDone", {
  group = lsp_completion,
  desc = "LSP completion",
  callback = function(args)
    local completion_item = vim.tbl_get(vim.v.completed_item, "user_data", "nvim", "lsp", "completion_item")
    if not completion_item then
      return
    end
    local clients = vim.lsp.get_active_clients()
    if #clients ~= 1 then
      return
    end -- TODO request ctx to be in user_data
    local client = clients[1]
    local bufnr = args.buf
    -- From cmp_nvim_lsp
    if vim.tbl_get(client.server_capabilities, "completionProvider", "resolveProvider") then
      client.request("completionItem/resolve", completion_item, function(_, result)
        -- print("resolve " .. vim.inspect(result)) -- TODO debug
        completion_item = result or completion_item
        complete(client, bufnr, vim.v.completed_item, completion_item)
      end)
      return
    end
    complete(client, bufnr, vim.v.completed_item, completion_item)
  end
})

complete = function(client, bufnr, completed_item, completion_item)
  -- print("completion_item " .. vim.inspect(completion_item)) -- TODO debug
  local snippet
  local completion_word
  if completion_item.textEdit then
    snippet = completion_item.textEdit.newText
    completion_word = require("vim.lsp.util").parse_snippet(snippet)
    local text_edit = vim.tbl_deep_extend("error", {}, completion_item.textEdit)
    text_edit.newText = completion_word
    if text_edit.replace then -- lsp.InsertReplaceEdit
      text_edit.range = text_edit.replace
    end
    local text_edits = { text_edit }
    if completion_item.additionalTextEdits then
      for _, text_edit in ipairs(completion_item.additionalTextEdits) do
        table.insert(text_edits, text_edit)
      end
    end
    vim.lsp.util.apply_text_edits(text_edits, bufnr, client.offset_encoding)
  else
    snippet = completion_item.insertText or completion_item.textEditText
    completion_word = require("vim.lsp.util").parse_snippet(snippet)
    if completion_item.additionalTextEdits then
      vim.lsp.util.apply_text_edits(completion_item.additionalTextEdits, bufnr, client.offset_encoding)
    end
    vim.api.nvim_put({ completion_word }, "", false, true)
  end
  -- print("snippet "..vim.inspect(snippet)) -- TODO debug
  -- print("completion_word "..vim.inspect(completion_word)) -- TODO debug
  return require("snippy").expand_snippet(snippet, completion_word)
end

local comp_list_to_comp_items = require("lbrayner.lsp.util").text_document_completion_list_to_complete_items
vim.lsp.util.text_document_completion_list_to_complete_items = comp_list_to_comp_items
