-- Typescript, Javascript
require("typescript").setup({
  server = {
    autostart = false,
  },
})

-- Python
require("lspconfig").pyright.setup {
  autostart = false,
}

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
local type_definition
local on_list
local quickfix_diagnostics_opts = {}
local lsp_setqflist

-- From nvim-lspconfig
local function on_attach(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  -- Some filetype plugins define omnifunc and $VIMRUNTIME/lua/vim/lsp.lua
  -- respects that, so we override it.
  vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

  -- Mappings
  local bufopts = { buffer=bufnr }
  vim.keymap.set("n", "<F11>", vim.lsp.buf.code_action, bufopts)
  vim.keymap.set("n", "gD", declaration, bufopts)
  vim.keymap.set("n", "gd", definition, bufopts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
  vim.keymap.set("n", "gi", implementation, bufopts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
  vim.keymap.set("n", "gK", vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set("n", "gy", type_definition, bufopts)

  -- Commands
  vim.api.nvim_buf_create_user_command(bufnr, "LspCodeAction", function(command)
    local range
    if command.line1 ~= command.line2 then
      range = {
        start = vim.api.nvim_buf_get_mark(0, "<"),
        ["end"] = vim.api.nvim_buf_get_mark(0, ">"),
      }
    end
    vim.lsp.buf.code_action({ range = range })
  end, { nargs=0, range=true })
  vim.api.nvim_buf_create_user_command(bufnr, "LspDeclaration", declaration, { nargs=0 })
  vim.api.nvim_buf_create_user_command(bufnr, "LspDocumentSymbol", vim.lsp.buf.document_symbol, {
    nargs=0 })
  vim.api.nvim_buf_create_user_command(bufnr, "LspDefinition", definition, { nargs=0 })
  vim.api.nvim_buf_create_user_command(bufnr, "LspDetach", function()
    for _, client in ipairs(vim.lsp.get_active_clients()) do
      vim.lsp.buf_detach_client(0, client.id)
    end
  end, { nargs=0 })
  vim.api.nvim_buf_create_user_command(bufnr, "LspFormat", function()
    vim.lsp.buf.format({ async=true })
  end, { nargs=0 })
  vim.api.nvim_buf_create_user_command(bufnr, "LspHover", vim.lsp.buf.hover, { nargs=0 })
  vim.api.nvim_buf_create_user_command(bufnr, "LspImplementation", implementation, { nargs=0 })
  vim.api.nvim_buf_create_user_command(bufnr, "LspReferences", vim.lsp.buf.references, { nargs=0 })
  vim.api.nvim_buf_create_user_command(bufnr, "LspRename", function(command)
    local name = command.args
    if name and name ~= "" then
      return vim.lsp.buf.rename(name)
    end
    vim.lsp.buf.rename()
  end, { nargs="?" })
  vim.api.nvim_buf_create_user_command(bufnr, "LspSignatureHelp", vim.lsp.buf.signature_help, {
    nargs=0 })
  vim.api.nvim_buf_create_user_command(bufnr, "LspTypeDefinition", type_definition, { nargs=0 })
  vim.api.nvim_buf_create_user_command(bufnr, "LspWorkspaceFolders", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, { nargs=0 })

  -- Diagnostic on quickfix
  vim.api.nvim_buf_create_user_command(bufnr, "LspDiagnosticQuickFixAll", function()
    lsp_setqflist({}, bufnr)
  end, { nargs=0 })
  vim.api.nvim_buf_create_user_command(bufnr, "LspDiagnosticQuickFixError", function()
    lsp_setqflist({ severity=vim.diagnostic.severity.ERROR }, bufnr)
  end, { nargs=0 })
  vim.api.nvim_buf_create_user_command(bufnr, "LspDiagnosticQuickFixWarn", function()
    lsp_setqflist({ severity={ min=vim.diagnostic.severity.WARN } }, bufnr)
  end, { nargs=0 })

  -- Custom statusline
  vim.b[bufnr].Statusline_custom_rightline = '%9*' .. client.name .. '%* '
  vim.b[bufnr].Statusline_custom_mod_rightline = '%9*' .. client.name .. '%* '
  vim.cmd "silent! doautocmd <nomodeline> User CustomStatusline"
end

local lsp_setup = vim.api.nvim_create_augroup("lsp_setup", { clear=true })

vim.api.nvim_create_autocmd("LspAttach", {
  group = lsp_setup,
  desc = "LSP buffer setup",
  callback = function(args)
    local bufnr = args.buf
    local clients
    if vim.tbl_get(args, "data") then
      clients = { vim.lsp.get_client_by_id(args.data.client_id) }
    else
      clients = vim.lsp.get_active_clients({ bufnr = bufnr })
    end
    for _, client in ipairs(clients) do
      on_attach(client, bufnr)
    end
  end,
})

vim.api.nvim_create_autocmd("LspDetach", {
  group = lsp_setup,
  desc = "Undo LSP buffer setup",
  callback = function(args)
    local bufnr = args.buf
    local clients
    if vim.tbl_get(args, "data") then
      clients = { vim.lsp.get_client_by_id(args.data.client_id) }
    else
      clients = vim.lsp.get_active_clients({ bufnr = bufnr })
    end

    for _, client in ipairs(clients) do

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
        vim.api.nvim_buf_del_user_command(bufnr, command)
      end
    end
  end,
})

vim.api.nvim_create_autocmd({ "DiagnosticChanged" }, {
  group = lsp_setup,
  callback = function()
    if vim.startswith(vim.fn.getqflist({ title=true }).title, "LSP Diagnostics") then
      vim.diagnostic.setqflist(vim.tbl_extend("error", quickfix_diagnostics_opts, {
        open=false
      }))
    end
  end,
})

declaration = function()
  vim.lsp.buf.declaration({ reuse_win=true })
end
definition = function()
  vim.lsp.buf.definition({ reuse_win=true })
end
implementation = function()
  vim.lsp.buf.implementation({ on_list=on_list })
end
type_definition = function()
  vim.lsp.buf.type_definition({ reuse_win=reuse_win })
end

on_list = function(options)
  vim.fn.setqflist({}, " ", options)
  if #options.items == 1  then
    local switchbuf = vim.go.switchbuf
    vim.go.switchbuf = "usetab,newtab"
    vim.cmd("cfirst")
    vim.go.switchbuf = switchbuf
    return
  end
  vim.cmd("botright copen")
end

lsp_setqflist = function(opts, bufnr)
  local active_clients = vim.lsp.get_active_clients({bufnr=bufnr})
  if #active_clients ~= 1 then
    quickfix_diagnostics_opts = vim.tbl_extend("error", opts, {
      title = "LSP Diagnostics"
    })
    return vim.diagnostic.setqflist(quickfix_diagnostics_opts)
  end
  local active_client = active_clients[1]
  quickfix_diagnostics_opts = vim.tbl_extend("error", opts, {
    namespace = vim.lsp.diagnostic.get_namespace(active_client.id),
    title = "LSP Diagnostics: " .. active_client.name
  })
  vim.diagnostic.setqflist(quickfix_diagnostics_opts)
end

local lspconfig_custom = vim.api.nvim_create_augroup("lspconfig_custom", { clear=true })

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  group = lspconfig_custom,
  desc = "New buffers attach to LS managed by lspconfig even when autostart is false",
  callback = function(args)
    for _, client in ipairs(vim.lsp.get_active_clients()) do
      if vim.tbl_get(client, "config", "workspace_folders") then
        local names = vim.tbl_map(function (workspace_folder)
          return workspace_folder.name
        end, client.config.workspace_folders)
        for _, name in ipairs(names) do
          if vim.startswith(vim.api.nvim_buf_get_name(args.buf), name) then
            if vim.fn.exists("#lspconfig#BufReadPost#" .. name .. "/*") == 1 then
              return vim.cmd("doautocmd lspconfig BufReadPost " .. name .. "/*")
            end
          end
        end
      end
    end
  end,
})
