local M = {}

-- Autocmds

local lsp_buffer = vim.api.nvim_create_augroup("lsp_buffer", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
  group = lsp_buffer,
  desc = "LSP buffer setup",
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    require("lbrayner.statusline").set_minor_modes(bufnr, client.name, "append")

    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, bufnr)
    end

    -- :h grr ($VIMRUNTIME/doc/lsp.txt)
    -- Some keymaps are created unconditionally when Nvim starts:
    -- - "grn" is mapped in Normal mode to |vim.lsp.buf.rename()|
    -- - "gra" is mapped in Normal and Visual mode to |vim.lsp.buf.code_action()|
    -- - "grr" is mapped in Normal mode to |vim.lsp.buf.references()|
    -- - "gri" is mapped in Normal mode to |vim.lsp.buf.implementation()|
    -- - "gO" is mapped in Normal mode to |vim.lsp.buf.document_symbol()|
    -- - CTRL-S is mapped in Insert mode to |vim.lsp.buf.signature_help()|

    -- Mappings
    local bufopts = { buffer = bufnr }
    vim.keymap.set({ "n", "v" }, "<F11>", vim.lsp.buf.code_action, bufopts)
    vim.keymap.set("n", "gD", M.declaration, bufopts)
    vim.keymap.set("n", "gd", M.definition, bufopts)
    vim.keymap.set("n", "K", M.hover, bufopts)
    vim.keymap.set("n", "gi", M.implementation, bufopts)
    vim.keymap.set("n", "gR", function()
      -- Exclude test references if not visiting a test file
      if M.is_test_file(vim.api.nvim_buf_get_name(0))
        == false then -- must be defined on site, returns nil if not available
        M.references({ no_tests = true })
        return
      end
      M.references()
    end, bufopts)
    vim.keymap.set("n", "gy", M.type_definition, bufopts)
  end,
})

vim.api.nvim_create_autocmd("LspDetach", {
  group = lsp_buffer,
  desc = "Undo LSP buffer setup",
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    require("lbrayner.statusline").set_minor_modes(bufnr, client.name, "remove")
  end,
})

local lsp_diagnostic = vim.api.nvim_create_augroup("lsp_diagnostic", { clear = true })

vim.api.nvim_create_autocmd("BufWritePost", {
  group = lsp_diagnostic,
  desc = "Update LSP Diagnostics quickfix list",
  callback = function(args)
    local bufnr = args.buf
    if vim.api.nvim_get_current_buf() ~= bufnr then
      -- After a BufWritePost do nothing if bufnr is not current
      return
    end
    if not vim.startswith(vim.fn.getqflist({ title = 1 }).title, "LSP Diagnostics") then
      -- Do nothing if qflist is not "LSP Diagnostics"
      return
    end
    M.diagnostic_setqflist({ open = false })
  end,
})

-- Set up the Lsp command
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    require("lbrayner.lsp._command")
  end,
})

-- Mappings

vim.keymap.set("n", "<F11>", function()
  vim.ui.select({ "Yes", "No" }, { prompt = "Start Language Server?" }, function(choice)
    if not choice then return end

    if choice == "Yes" then
      vim.cmd("LspStart")
    end
  end)
end)

local get_proxy = require("lbrayner").get_proxy_table_for_module

M.diagnostic = get_proxy("lbrayner.lsp._diagnostic")
M.lib = get_proxy("lbrayner.lsp._lib")
M.operations = get_proxy("lbrayner.lsp._operations")
M.site = get_proxy("lbrayner.lsp._site")

local function get(proxy, key)
  if not rawget(M, key) then
    rawset(M, key, function(...)
      return proxy[key](...)
    end)
  end
  return rawget(M, key)
end

return setmetatable(M, {
  __index = function(_, key)
    if vim.list_contains(
      {
        "diagnostic_setqflist",
      }, key) then
      return get(M.diagnostic, key)
    end
    if vim.list_contains(
      {
        "on_list",
      }, key) then
      return get(M.lib, key)
    end
    if vim.list_contains(
      {
        "declaration",
        "definition",
        "hover",
        "implementation",
        "references",
        "type_definition",
      }, key) then
      return get(M.operations, key)
    end
    if vim.list_contains(
      {
        "is_test_file",
      }, key) then
      return get(M.site, key)
    end
  end,
  __newindex = function()
    error("Cannot add item")
  end,
})
