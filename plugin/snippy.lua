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

vim.api.nvim_create_autocmd("CompleteDonePre", {
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
    print("completed_item " .. vim.inspect(vim.v.completed_item))
    if completion_item.additionalTextEdits then
      vim.lsp.util.apply_text_edits(completion_item.additionalTextEdits, bufnr, client.offset_encoding)
      local word = vim.v.completed_item.user_data.word
      if word ~= vim.v.completed_item.word then
        local pos = vim.fn.getpos(".")
        local line = pos[2] - 1
        local col = pos[3] - 1
        vim.api.nvim_buf_set_text(bufnr, line, col, line, col, { word })
        vim.api.nvim_win_set_cursor(0, { pos[2], col + string.len(word) })
        require("snippy").expand_snippet(completion_item.insertText, word)
        return
      end
    end
    require("snippy").complete_done()
  end
})
