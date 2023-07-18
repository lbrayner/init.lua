local mappings = require("snippy.mapping")

vim.keymap.set({ "i", "s" }, "<C-Tab>", mappings.next())
-- Overrides delimitMate's <S-Tab> mapping
vim.keymap.set({ "i", "s" }, "<S-Tab>", mappings.previous())
-- TODO analyze the utility of cut_text
-- vim.keymap.set("x", "<Tab>", mappings.cut_text, { remap = true })
-- vim.keymap.set("n", "g<Tab>", mappings.cut_text, { remap = true })

local InsertTextFormat = vim.lsp.protocol.InsertTextFormat
local snip_comp_done = vim.api.nvim_create_augroup("snip_comp_done", { clear = true })

local comp_list_to_comp_items = require("lbrayner.lsp.util").text_document_completion_list_to_complete_items
vim.lsp.util.text_document_completion_list_to_complete_items = comp_list_to_comp_items

vim.api.nvim_create_autocmd("CompleteDone", {
  group = snip_comp_done,
  desc = "Snippy LSP snippet expansion in completion items",
  callback = function(args)
    local completion_item = vim.tbl_get(vim.v.completed_item, "user_data", "nvim", "lsp", "completion_item")
    if not completion_item then
      return
    end
    if completion_item.insertTextFormat ~= InsertTextFormat.Snippet then
      return
    end
    local clients = vim.lsp.get_active_clients()
    if #clients ~= 1 then
      return require("snippy").complete_done()
    end -- TODO request ctx to be in user_data
    local client = clients[1]
    local bufnr = args.buf
    -- print("completed_item " .. vim.inspect(vim.v.completed_item)) -- TODO debug
    if completion_item.additionalTextEdits then
      local snippet
      local completion_word = vim.v.completed_item.user_data.nvim.lsp.completion_word
      if completion_item.textEdit then
        local text_edit = vim.tbl_deep_extend("error", {}, completion_item.textEdit)
        snippet = text_edit.newText
        text_edit.newText = completion_word
        local text_edits = { text_edit }
        for _, text_edit in ipairs(completion_item.additionalTextEdits) do
          table.insert(text_edits, text_edit)
        end
        vim.lsp.util.apply_text_edits(text_edits, bufnr, client.offset_encoding)
      elseif completion_word ~= vim.v.completed_item.word then
        snippet = completed_item.insertText
        vim.lsp.util.apply_text_edits(completion_item.additionalTextEdits, bufnr, client.offset_encoding)
        vim.api.nvim_put({ completion_word }, "", false, true)
      end
      return require("snippy").expand_snippet(snippet, completion_word)
    end
    require("snippy").complete_done()
  end
})
