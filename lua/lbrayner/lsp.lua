local M = {}

M.operations = require("lbrayner").get_reloadable_module("lbrayner.lsp._operations")

function M.declaration()
  M.operations.declaration()
end

function M.definition()
  M.operations.definition()
end

M.diagnostic = require("lbrayner").get_reloadable_module("lbrayner.lsp._diagnostic")

function M.diagnostic_setqflist(opts)
  M.diagnostic.diagnostic_setqflist(opts)
end

function M.hover()
  M.operations.hover()
end

function M.implementation()
  M.operations.implementation()
end

M.site = require("lbrayner").get_reloadable_module("lbrayner.lsp._site")

function M.is_test_file()
  M.site.is_test_file()
end

M.lib = require("lbrayner").get_reloadable_module("lbrayner.lsp._lib")

function M.on_list(options)
  M.lib.on_list(options)
end

function M.references(config)
  M.operations.references(config)
end

function M.type_definition()
  M.operations.type_definition()
end

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
      -- vim.lsp.completion.enable(true, client.id, bufnr)
      require("lbrayner.lsp.completion").enable(true, client.id, bufnr)

      -- Enable completion triggered by <c-x><c-o>
      -- Some filetype plugins define omnifunc and $VIMRUNTIME/lua/vim/lsp.lua
      -- respects that, so we override it.
      vim.bo[bufnr].omnifunc = "v:lua.require'lbrayner.lsp.completion'._omnifunc"
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

local lspconfig_custom = vim.api.nvim_create_augroup("lspconfig_custom", { clear = true })

vim.api.nvim_create_autocmd("BufNewFile", {
  group = lspconfig_custom,
  desc = "New buffers attach to language servers managed by lspconfig even when autostart is false",
  callback = function(args)
    local bufnr = args.buf
    local bufname = vim.api.nvim_buf_get_name(bufnr)

    vim.schedule(function()
      vim.api.nvim_exec_autocmds("BufRead", { group = "lspconfig", pattern = bufname })
    end)
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

return M
