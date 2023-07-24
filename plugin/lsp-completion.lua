local mappings = require("snippy.mapping")

vim.keymap.set({ "i", "s" }, "<C-Tab>", mappings.next())
-- Overrides delimitMate's <S-Tab> mapping
vim.keymap.set({ "i", "s" }, "<S-Tab>", mappings.previous())
-- TODO analyze the utility of cut_text
-- vim.keymap.set("x", "<Tab>", mappings.cut_text, { remap = true })
-- vim.keymap.set("n", "g<Tab>", mappings.cut_text, { remap = true })

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
    print("completion_item "..vim.inspect(completion_item)) -- TODO debug
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

local InsertTextFormat = vim.lsp.protocol.InsertTextFormat

complete = function(client, bufnr, completed_item, completion_item)
  print("completed_item " .. vim.inspect(completed_item)) -- TODO debug
  print("completion_item " .. vim.inspect(completion_item)) -- TODO debug
  local is_snippet = completion_item.insertTextFormat ~= InsertTextFormat.Snippet
  local new_text
  if completion_item.textEdit then
    new_text = completion_item.textEdit.newText
    local text_edit = vim.tbl_deep_extend("error", {}, completion_item.textEdit)
    if is_snippet then
      text_edit.newText = ""
    end
    if text_edit.replace then -- lsp.InsertReplaceEdit
      text_edit.range = text_edit.replace
    end
    print("new_text "..vim.inspect(new_text)) -- TODO debug
    local text_edits = { text_edit }
    if completion_item.additionalTextEdits then
      for _, text_edit in ipairs(completion_item.additionalTextEdits) do
        table.insert(text_edits, text_edit)
      end
    end
    vim.lsp.util.apply_text_edits(text_edits, bufnr, client.offset_encoding)
  else
    new_text = completion_item.insertText or completion_item.textEditText
    if completion_item.additionalTextEdits then
      vim.lsp.util.apply_text_edits(completion_item.additionalTextEdits, bufnr, client.offset_encoding)
    end
    if not is_snippet then
      vim.api.nvim_put({ new_text }, "", false, true)
    end
  end
  if is_snippet then
    require("snippy").expand_snippet(new_text)
  end
end
