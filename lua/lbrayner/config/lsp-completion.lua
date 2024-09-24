local mappings = require("snippy.mapping")

vim.keymap.set({ "i", "s" }, "<C-Tab>", mappings.next())
vim.keymap.set({ "i", "s" }, "<S-Tab>", mappings.previous())
-- TODO analyze the utility of cut_text
-- vim.keymap.set("x", "<Tab>", mappings.cut_text, { remap = true })
-- vim.keymap.set("n", "g<Tab>", mappings.cut_text, { remap = true })

local completion_accepted

vim.keymap.set("i", "<C-Y>", function()
  if vim.fn.pumvisible() == 1 then
    completion_accepted = true
  end
  return "<C-Y>"
end, { expr = true })

local complete

local lsp_completion = vim.api.nvim_create_augroup("lsp_completion", { clear = true })

vim.api.nvim_create_autocmd("CompleteDonePre", {
  group = lsp_completion,
  desc = "LSP completion",
  callback = function(args)
    if completion_accepted then
      completion_accepted = nil
    else
      return
    end

    local completed_item = vim.v.completed_item
    local lsp = vim.tbl_get(completed_item, "user_data", "nvim", "lsp")

    if not lsp then
      return
    end

    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(lsp.client_id)
    local completion_item = lsp.completion_item

    -- From cmp_nvim_lsp
    if vim.tbl_get(client.capabilities, "textDocument", "completion", "resolveSupport") and
      vim.tbl_get(client.server_capabilities, "completionProvider", "resolveProvider") then
      client.request("completionItem/resolve", completion_item, function(_, result)
        completion_item = result or completion_item
        complete(client, bufnr, completed_item, completion_item)
      end)
      return
    end

    complete(client, bufnr, completed_item, completion_item)
  end
})

complete = function(client, bufnr, completed_item, completion_item)
  local is_snippet = completion_item.insertTextFormat == vim.lsp.protocol.InsertTextFormat.Snippet
  local new_text
  local word

  if completion_item.textEdit then
    -- Delayed completion
    -- Do textEdit, then possibly additionalTextEdits
    -- Typically an auto-import
    local text_edit = completion_item.textEdit
    new_text = text_edit.newText

    if is_snippet then
      text_edit.newText = ""
    end

    if text_edit.replace then -- lsp.InsertReplaceEdit
      text_edit.range = text_edit.replace
    end

    local text_edits = { text_edit }

    if completion_item.additionalTextEdits then
      vim.list_extend(text_edits, completion_item.additionalTextEdits)
    end

    vim.lsp.util.apply_text_edits(text_edits, bufnr, client.offset_encoding)
  elseif completion_item.additionalTextEdits then
    -- Delayed completion
    -- Do additionalTextEdits, then insert insertText
    -- eclipse.jdt.ls postfix snippets
    vim.lsp.util.apply_text_edits(completion_item.additionalTextEdits, bufnr, client.offset_encoding)

    new_text = completion_item.insertText or completion_item.textEditText or completion_item.label

    if not is_snippet then
      vim.api.nvim_put({ new_text }, "", false, true)
    end
  elseif is_snippet then
    -- Expand snippet of a regular completion
    -- textEditText only possible if there are itemDefaults with a range
    new_text = completion_item.insertText or completion_item.label
    word = completed_item.word
  end

  if is_snippet then
    require("snippy").expand_snippet(new_text, word)
  end
end
