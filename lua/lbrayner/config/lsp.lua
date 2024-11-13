-- Commands

---@type table<string, MyCmdSubcommand>
local subcommand_tbl = {}
require("lbrayner.subcommands").create_command_and_subcommands("Lsp", subcommand_tbl, {
  desc = "Lsp and subcommands",
  range = true
})

-- Lua
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#lua_ls
require("lspconfig").lua_ls.setup({
  autostart = false,
  capabilities = require("lbrayner.lsp").default_capabilities(),
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you"re using (most
        -- likely LuaJIT in the case of Neovim)
        version = "LuaJIT",
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = { "vim" },
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
})

local declaration
local definition
local implementation
local references
local type_definition
local is_test_file

-- From nvim-lspconfig. 'client' is not used.
local function on_attach(_, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  -- Some filetype plugins define omnifunc and $VIMRUNTIME/lua/vim/lsp.lua
  -- respects that, so we override it.
  vim.bo[bufnr].omnifunc = "v:lua.require'lbrayner.lsp._completion'.omnifunc"

  -- Mappings
  local bufopts = { buffer = bufnr }
  vim.keymap.set({ "n", "v" }, "<F11>", vim.lsp.buf.code_action, bufopts)
  vim.keymap.set("n", "gD", declaration, bufopts)
  vim.keymap.set("n", "gd", definition, bufopts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
  vim.keymap.set("n", "gi", implementation, bufopts)
  vim.keymap.set("n", "gr", function()
    -- Exclude test references if not visiting a test file
    if is_test_file and not is_test_file(vim.api.nvim_buf_get_name(0)) then
      references({ no_tests = true })
      return
    end
    references()
  end, bufopts)
  vim.keymap.set("n", "gK", vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set("n", "gy", type_definition, bufopts)

  -- Commands
  vim.api.nvim_buf_create_user_command(bufnr, "LspReferences", references, { nargs = 0 })
  vim.api.nvim_buf_create_user_command(bufnr, "LspReferencesNoTests", function()
    references({ no_tests = true })
  end, { nargs = 0 })
  vim.api.nvim_buf_create_user_command(bufnr, "LspRemoveWorkspaceFolder", function(command)
    local dir = command.args
    if dir == "" then
      dir = vim.fn.getcwd()
    end
    vim.lsp.buf.remove_workspace_folder(dir)
  end, { complete = "file", nargs = "?" })
  vim.api.nvim_buf_create_user_command(bufnr, "LspWorkspaceFolders", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, { nargs = 0 })
  vim.api.nvim_buf_create_user_command(bufnr, "LspWorkspaceSymbol", function(command)
    local name = command.args
    if name and name ~= "" then
      vim.lsp.buf.workspace_symbol(name)
      return
    end
    vim.lsp.buf.workspace_symbol()
  end, { nargs = "?" })
end

local lsp_set_statusline
local lsp_setup = vim.api.nvim_create_augroup("lsp_setup", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
  group = lsp_setup,
  desc = "LSP buffer setup",
  callback = function(args)
    local bufnr = args.buf
    local clients = vim.lsp.get_clients({ bufnr = bufnr })

    if #clients == 0 then return end

    lsp_set_statusline(clients, bufnr)
    on_attach(nil, bufnr)
  end,
})

vim.api.nvim_create_autocmd("LspDetach", {
  group = lsp_setup,
  desc = "Undo LSP buffer setup",
  callback = function(args)
    local bufnr = args.buf
    local clients = vim.lsp.get_clients({ bufnr = bufnr })

    if vim.tbl_get(args, "data") and #clients > 1 then
      local other_clients = vim.tbl_filter(function(client)
        return client.id ~= args.data.client_id
      end, clients)

      lsp_set_statusline(other_clients, bufnr)
      return
    end

    -- Restore the statusline
    vim.b[bufnr].Statusline_custom_rightline = nil
    vim.b[bufnr].Statusline_custom_mod_rightline = nil

    if vim.api.nvim_get_current_buf() == bufnr then
      vim.api.nvim_exec_autocmds("User", { modeline = false, pattern = "CustomStatusline" })
    end

    -- Delete user commands
    for _, command in ipairs({
      "LspReferences",
      "LspRemoveWorkspaceFolder",
      "LspWorkspaceFolders",
      "LspWorkspaceSymbol",
    }) do
      pcall(vim.api.nvim_buf_del_user_command, bufnr, command) -- Ignore error if command doesn't exist
    end
  end,
})

local lsp_setqflist_replace
local quickfix_diagnostics_opts = {}

vim.api.nvim_create_autocmd("DiagnosticChanged", {
  group = lsp_setup,
  callback = function()
    if not vim.startswith(vim.fn.getqflist({ title = true }).title, "LSP Diagnostics") then return end

    if not quickfix_diagnostics_opts.namespace then return end

    lsp_setqflist_replace()
  end,
})

local lspconfig_custom = vim.api.nvim_create_augroup("lspconfig_custom", { clear = true })

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  group = lspconfig_custom,
  desc = "New buffers attach to language servers managed by lspconfig even when autostart is false",
  callback = function(args)
    local bufnr = args.buf
    for _, client in ipairs(vim.lsp.get_clients()) do
      if vim.tbl_get(client, "config", "workspace_folders") then
        local folder_names = vim.tbl_map(function (workspace_folder)
          return workspace_folder.name
        end, client.config.workspace_folders)
        for _, folder_name in ipairs(folder_names) do
          local bufname = vim.api.nvim_buf_get_name(bufnr)
          if vim.startswith(bufname, folder_name) then
            if vim.fn.exists("#lspconfig#BufRead#" .. folder_name .. "/*") == 1 then
              vim.api.nvim_exec_autocmds("BufRead", { group = "lspconfig", pattern = bufname })
              return
            end
          end
        end
      end
    end
  end,
})

-- Handler configuration

vim.lsp.buf.on_hover = vim.lsp.handlers["textDocument/hover"]

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.buf.on_hover, {
  close_events = require("lbrayner").get_close_events(),
})

-- Definitions {{{

lsp_set_statusline = function(clients, bufnr)
  local names = vim.tbl_map(function (client)
    return client.name
  end, clients)
  table.sort(names)
  local stl_lsp = table.concat(names, ",") -- joining items with a separator

  -- Custom statusline
  vim.b[bufnr].Statusline_custom_rightline = '%9*' .. stl_lsp .. '%* '
  vim.b[bufnr].Statusline_custom_mod_rightline = '%9*' .. stl_lsp .. '%* '
  if vim.api.nvim_get_current_buf() == bufnr then
    vim.api.nvim_exec_autocmds("User", { modeline = false, pattern = "CustomStatusline" })
  end
end

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
  local context = { includeDeclaration = false }

  config = config or {}

  if is_test_file and config.no_tests then
    vim.lsp.buf.references(context, { on_list = function(options)
      options.items = vim.tbl_filter(function(item)
        -- Filter out tests
        return not is_test_file(item.filename)
      end, options.items)
      on_list(options)
    end })
    return
  end

  vim.lsp.buf.references(context, { on_list = on_list })
end
type_definition = function()
  vim.lsp.buf.type_definition({ on_list = on_list, reuse_win = true })
end

is_test_file = (function()
  local success, site = pcall(require, "lbrayner.site.lsp")

  if success then
    return function(filename)
      return site.is_test_file(filename)
    end
  end

  return nil
end)()

local function get_range(command)
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

lsp_setqflist_replace = function()
  local diagnostics = vim.diagnostic.get(nil, quickfix_diagnostics_opts)
  local items = vim.diagnostic.toqflist(diagnostics)

  vim.fn.setqflist({}, "r", { title = quickfix_diagnostics_opts.title, items = items })
end

local function lsp_setqflist(opts)
  local bufnr = vim.api.nvim_get_current_buf()
  local active_clients = vim.lsp.get_clients({ bufnr = bufnr })
  if #active_clients ~= 1 then
    -- Only one client supported.
    return
  end

  local active_client = active_clients[1]

  quickfix_diagnostics_opts = vim.tbl_extend("keep", {
    namespace = vim.lsp.diagnostic.get_namespace(active_client.id),
  }, opts, quickfix_diagnostics_opts)

  local title = "LSP Diagnostics: " .. active_client.name

  local severity = quickfix_diagnostics_opts.severity
  if type(severity) == "table" then severity = severity.min end
  if severity then
    title = string.format("%s (%s)", title, vim.diagnostic.severity[severity])
  end

  quickfix_diagnostics_opts.title = title

  if vim.fn.getqflist({ title = true }).title == quickfix_diagnostics_opts.title then
    lsp_setqflist_replace()
    vim.cmd("botright copen")
    return
  end

  vim.diagnostic.setqflist(quickfix_diagnostics_opts)
end

subcommand_tbl.addWorkspaceFolder = {
  complete = require("lbrayner.subcommands").complete_filename,
  impl = function(args, _)
    local dir = table.concat(args, " ")
    if dir == "" then
      dir = vim.fn.getcwd()
    else
      dir = vim.fn.fnamemodify(dir, ":p") -- In case ".", "..", etc. are supplied
    end
    vim.lsp.buf.add_workspace_folder(dir)
  end,
}

subcommand_tbl.codeAction = {
  simple = function(opts)
    vim.lsp.buf.code_action({ range = get_range(opts) })
  end,
}

subcommand_tbl.declaration = {
  simple = function(_)
    declaration()
  end,
}

subcommand_tbl.definition = {
  simple = function(_)
    definition()
  end,
}

subcommand_tbl.diagnostic = {
  subcommand_tbl = {
    all = {
      simple = function(_)
        quickfix_diagnostics_opts.severity = nil
        lsp_setqflist({})
      end,
    },
    error = {
      simple = function(_)
        lsp_setqflist({ severity = vim.diagnostic.severity.ERROR })
      end,
    },
    warn = {
      simple = function(_)
        lsp_setqflist({ severity = { min = vim.diagnostic.severity.WARN } })
      end,
    },
  },
}
subcommand_tbl.detach = {
  simple = function(_)
    for _, client in ipairs(vim.lsp.get_clients()) do
      vim.lsp.buf_detach_client(0, client.id)
    end
  end,
}

subcommand_tbl.documentSymbol = {
  simple = function(_)
    vim.lsp.buf.document_symbol()
  end,
}

subcommand_tbl.format = {
  simple = function(opts)
    vim.lsp.buf.format({ async = true, range = get_range(opts) })
  end,
}

subcommand_tbl.hover = {
  simple = function(_)
    vim.lsp.buf.hover()
  end,
}

subcommand_tbl.implementation = {
  simple = function(_)
    implementation()
  end,
}

subcommand_tbl.rename = {
  impl = function(args, _)
    local name = table.concat(args, " ")
    if name and name ~= "" then
      vim.lsp.buf.rename(name)
      return
    end
    vim.lsp.buf.rename()
  end,
}

subcommand_tbl.signatureHelp = {
  simple = function(_)
    vim.lsp.buf.signature_help()
  end,
}

subcommand_tbl.typeDefinition = {
  simple = function(_)
    type_definition()
  end,
}

-- }}}

-- vim: fdm=marker
