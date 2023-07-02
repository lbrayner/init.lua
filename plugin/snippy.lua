local mappings = require("snippy.mapping")

vim.keymap.set({ "i", "s" }, "<C-Tab>", mappings.next())
-- Overrides delimitMate's <S-Tab> mapping
vim.keymap.set({ "i", "s" }, "<S-Tab>", mappings.previous())
-- TODO analyze the utility of cut_text
-- vim.keymap.set("x", "<Tab>", mappings.cut_text, { remap = true })
-- vim.keymap.set("n", "g<Tab>", mappings.cut_text, { remap = true })

local snip_comp_done = vim.api.nvim_create_augroup("snip_comp_done", { clear = true })

vim.api.nvim_create_autocmd("CompleteDone", {
  group = snip_comp_done,
  desc = "Snippy LSP snippet expansion in completion items",
  callback = function(args)
    local completion_item = vim.tbl_get(vim.v.completed_item, "user_data", "nvim", "lsp", "completion_item")
    if not completion_item then
      return
    end
    local clients = vim.lsp.get_active_clients()
    if #clients ~= 1 then
      return require("snippy").complete_done()
    end -- TODO request ctx to be in user_data
    local client = clients[1]
    local bufnr = args.buf
    if completion_item.additionalTextEdits then
      vim.lsp.util.apply_text_edits(completion_item.additionalTextEdits, bufnr, client.offset_encoding)
    end
    require("snippy").complete_done()
  end
})
