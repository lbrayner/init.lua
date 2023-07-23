local capabilities = require("lbrayner.lsp").default_capabilities()

-- Typescript, Javascript
require("typescript").setup({
  server = {
    autostart = false,
    capabilities = capabilities,
  },
})

-- Python
require("lspconfig").pyright.setup {
  autostart = false,
}

-- Lua
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#lua_ls
require("lspconfig").lua_ls.setup {
  autostart = false,
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you"re using (most
        -- likely LuaJIT in the case of Neovim)
        version = "LuaJIT",
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = {"vim"},
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
      },
      -- Do not send telemetry data containing a randomized but unique
      -- identifier
      telemetry = {
        enable = false,
      },
    },
  },
}

local declaration
local definition
local implementation
local references
local type_definition
local is_test_file
local get_range
local quickfix_diagnostics_opts = {}
local lsp_setqflist

-- From nvim-lspconfig. 'client' is not used.
local function on_attach(_, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  -- Some filetype plugins define omnifunc and $VIMRUNTIME/lua/vim/lsp.lua
  -- respects that, so we override it.
  vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.require'lbrayner.lsp'.omnifunc")

  -- Mappings
  local bufopts = { buffer = bufnr }
  vim.keymap.set({ "n", "v" }, "<F11>", vim.lsp.buf.code_action, bufopts)
  vim.keymap.set("n", "gD", declaration, bufopts)
  vim.keymap.set("n", "gd", definition, bufopts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
  vim.keymap.set("n", "gi", implementation, bufopts)
  vim.keymap.set("n", "gr", function()
    -- Exclude test references if not visiting a test file
    if not is_test_file(vim.api.nvim_buf_get_name(0)) then
      return references({ no_tests = true })
    end
    references()
  end, bufopts)
  vim.keymap.set("n", "gK", vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set("n", "gy", type_definition, bufopts)

  -- Commands
  vim.api.nvim_buf_create_user_command(bufnr, "LspCodeAction", function(command)
    vim.lsp.buf.code_action({ range = get_range(command) })
  end, { nargs = 0, range = true })
  vim.api.nvim_buf_create_user_command(bufnr, "LspDeclaration", declaration, { nargs = 0 })
  vim.api.nvim_buf_create_user_command(bufnr, "LspDocumentSymbol", vim.lsp.buf.document_symbol, {
    nargs = 0 })
  vim.api.nvim_buf_create_user_command(bufnr, "LspDefinition", definition, { nargs = 0 })
  vim.api.nvim_buf_create_user_command(bufnr, "LspDetach", function()
    for _, client in ipairs(vim.lsp.get_active_clients()) do
      vim.lsp.buf_detach_client(0, client.id)
    end
  end, { nargs = 0 })
  vim.api.nvim_buf_create_user_command(bufnr, "LspFormat", function(command)
    vim.lsp.buf.format({ async = true, range = get_range(command) })
  end, { nargs = 0, range = "%" })
  vim.api.nvim_buf_create_user_command(bufnr, "LspHover", vim.lsp.buf.hover, { nargs = 0 })
  vim.api.nvim_buf_create_user_command(bufnr, "LspImplementation", implementation, { nargs = 0 })
  vim.api.nvim_buf_create_user_command(bufnr, "LspReferences", references, { nargs = 0 })
  vim.api.nvim_buf_create_user_command(bufnr, "LspReferencesNoTests", function()
    references({ no_tests = true })
  end, { nargs = 0 })
  vim.api.nvim_buf_create_user_command(bufnr, "LspRename", function(command)
    local name = command.args
    if name and name ~= "" then
      return vim.lsp.buf.rename(name)
    end
    vim.lsp.buf.rename()
  end, { nargs = "?" })
  vim.api.nvim_buf_create_user_command(bufnr, "LspSignatureHelp", vim.lsp.buf.signature_help, {
    nargs = 0 })
  vim.api.nvim_buf_create_user_command(bufnr, "LspTypeDefinition", type_definition, { nargs = 0 })
  vim.api.nvim_buf_create_user_command(bufnr, "LspWorkspaceFolders", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, { nargs = 0 })

  -- Diagnostic on quickfix
  vim.api.nvim_buf_create_user_command(bufnr, "LspDiagnosticQuickFixAll", function()
    lsp_setqflist({}, bufnr)
  end, { nargs = 0 })
  vim.api.nvim_buf_create_user_command(bufnr, "LspDiagnosticQuickFixError", function()
    lsp_setqflist({ severity = vim.diagnostic.severity.ERROR }, bufnr)
  end, { nargs = 0 })
  vim.api.nvim_buf_create_user_command(bufnr, "LspDiagnosticQuickFixWarn", function()
    lsp_setqflist({ severity = { min = vim.diagnostic.severity.WARN } }, bufnr)
  end, { nargs = 0 })
end

local lsp_setup = vim.api.nvim_create_augroup("lsp_setup", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
  group = lsp_setup,
  desc = "LSP buffer setup",
  callback = function(args)
    local clients = {}
    local bufnr = args.buf
    if vim.tbl_get(args, "data") then
      clients = { vim.lsp.get_client_by_id(args.data.client_id) }
    else
      clients = vim.lsp.get_active_clients({ bufnr = bufnr })
    end

    if #clients == 0 then return end

    on_attach(nil, bufnr)

    local names = vim.tbl_map(function (client)
      return client.name
    end, clients)
    local stl_lsp = table.concat(names, ",") -- joining items with a separator

    -- Custom statusline
    vim.b[bufnr].Statusline_custom_rightline = '%9*' .. stl_lsp .. '%* '
    vim.b[bufnr].Statusline_custom_mod_rightline = '%9*' .. stl_lsp .. '%* '
    vim.cmd "silent! doautocmd <nomodeline> User CustomStatusline"
  end,
})

vim.api.nvim_create_autocmd("LspDetach", {
  group = lsp_setup,
  desc = "Undo LSP buffer setup",
  callback = function(args)
    local clients = {}
    local bufnr = args.buf
    if vim.tbl_get(args, "data") then
      clients = { vim.lsp.get_client_by_id(args.data.client_id) }
    else
      clients = vim.lsp.get_active_clients({ bufnr = bufnr })
    end

    if #clients == 0 then return end

    -- Restore the statusline
    vim.b[bufnr].Statusline_custom_rightline = nil
    vim.b[bufnr].Statusline_custom_mod_rightline = nil

    -- Delete user commands
    for _, command in ipairs({
      "LspCodeAction",
      "LspDeclaration",
      "LspDocumentSymbol",
      "LspDefinition",
      "LspDetach",
      "LspFormat",
      "LspHover",
      "LspImplementation",
      "LspReferences",
      "LspRename",
      "LspSignatureHelp",
      "LspTypeDefinition",
      "LspWorkspaceFolders",
      "LspDiagnosticQuickFixAll",
      "LspDiagnosticQuickFixError",
      "LspDiagnosticQuickFixWarn" }) do
      pcall(vim.api.nvim_buf_del_user_command, bufnr, command) -- Ignore error if command doesn't exist
    end
  end,
})

vim.api.nvim_create_autocmd({ "DiagnosticChanged" }, {
  group = lsp_setup,
  callback = function()
    if vim.startswith(vim.fn.getqflist({ title = true }).title, "LSP Diagnostics") then
      lsp_setqflist({ open = false })
    end
  end,
})

local on_list = require("lbrayner.lsp").on_list

declaration = function()
  vim.lsp.buf.declaration({ on_list = on_list, reuse_win = true })
end
definition = function()
  vim.lsp.buf.definition({ on_list = on_list, reuse_win = true })
end
-- Documentation is missing reuse_win
implementation = function()
  vim.lsp.buf.implementation({ on_list = on_list, reuse_win = true })
end
references = function(config)
  config = config or {}
  if config.no_tests then
    return vim.lsp.buf.references(nil, { on_list = function(options)
      options.items = vim.tbl_filter(function(item)
        -- Filter out tests
        return not is_test_file(item.filename)
      end, options.items)
      on_list(options)
    end })
  end
  vim.lsp.buf.references(nil, { on_list = on_list })
end
type_definition = function()
  vim.lsp.buf.type_definition({ on_list = on_list, reuse_win = true })
end

is_test_file = function(filename)
  return string.find(vim.fn.fnamemodify(filename, ":t"), "[tT]est.")
end

get_range = function(command)
  -- Visual selection
  local range = {
    start = vim.api.nvim_buf_get_mark(0, "<"),
    ["end"] = vim.api.nvim_buf_get_mark(0, ">")
  }
  if command.line1 ~= range.start[1] or
    command.line2 ~= range["end"][1] then
    -- Supplied range inferred
    range = {
      start = { command.line1, 0 },
      ["end"] = { command.line2, 2147483647 }, -- Maximum line length (vi_diff.txt)
    }
  end
  return range
end

lsp_setqflist = function(opts, bufnr)
  local active_clients = vim.lsp.get_active_clients({ bufnr = bufnr })
  if #active_clients ~= 1 then
    quickfix_diagnostics_opts = vim.tbl_extend("keep", {
      title = "LSP Diagnostics"
    }, opts, quickfix_diagnostics_opts)
    return vim.diagnostic.setqflist(quickfix_diagnostics_opts)
  end
  local active_client = active_clients[1]
  quickfix_diagnostics_opts = vim.tbl_extend("keep", {
    namespace = vim.lsp.diagnostic.get_namespace(active_client.id),
    title = "LSP Diagnostics: " .. active_client.name
  }, opts, quickfix_diagnostics_opts)
  vim.diagnostic.setqflist(quickfix_diagnostics_opts)
end

local lspconfig_custom = vim.api.nvim_create_augroup("lspconfig_custom", { clear = true })

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  group = lspconfig_custom,
  desc = "New buffers attach to language servers managed by lspconfig even when autostart is false",
  callback = function(args)
    local bufnr = args.buf
    for _, client in ipairs(vim.lsp.get_active_clients()) do
      if vim.tbl_get(client, "config", "workspace_folders") then
        local folder_names = vim.tbl_map(function (workspace_folder)
          return workspace_folder.name
        end, client.config.workspace_folders)
        for _, folder_name in ipairs(folder_names) do
          local bufname = vim.api.nvim_buf_get_name(bufnr)
          if vim.startswith(bufname, folder_name) then
            if vim.fn.exists("#lspconfig#BufReadPost#" .. folder_name .. "/*") == 1 then
              return vim.cmd("doautocmd lspconfig BufReadPost " .. bufname)
            end
          end
        end
      end
    end
  end,
})
