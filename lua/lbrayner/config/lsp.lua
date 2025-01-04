-- vim: fdm=marker

-- {{{

local is_test_file = (function()
  local success, site = pcall(require, "lbrayner.site.lsp")

  if success then
    return function(filename)
      return site.is_test_file(filename)
    end
  end

  return nil
end)()

local diagnostic_qf_opts = {}

local function diagnostic_setqflist(opts)
  opts = opts or {}
  opts.open = opts.open == nil and true or opts.open
  local clients = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })
  local diagnostics = {}

  for _, client in ipairs(clients) do
    diagnostic_qf_opts = vim.tbl_extend("keep", {
      namespace = vim.lsp.diagnostic.get_namespace(client.id),
    }, opts, diagnostic_qf_opts)

    vim.list_extend(diagnostics, vim.diagnostic.get(nil, diagnostic_qf_opts))
  end

  local names = vim.tbl_map(function (client)
    return client.name
  end, clients)

  table.sort(names)

  local title = "LSP Diagnostics: " .. table.concat(names, ",") -- joining items with a separator
  local severity = diagnostic_qf_opts.severity

  if severity then
    if type(severity) == "table" then severity = severity.min end
    title = string.format("%s (%s)", title, vim.diagnostic.severity[severity])
  end

  diagnostic_qf_opts.title = title

  local action = " "
  local items = vim.diagnostic.toqflist(diagnostics)
  local qflist = vim.fn.getqflist({ title = 1, winid = 1 })

  if qflist.title == title then
    action = "u"
  end

  vim.fn.setqflist({}, action, { title = title, items = items })

  if opts.open and qflist.winid == 0 then
    vim.cmd("botright copen")
  end
end

local on_list = require("lbrayner.lsp").on_list

local function declaration()
  vim.lsp.buf.declaration({ on_list = on_list, reuse_win = true })
end

local function definition()
  vim.lsp.buf.definition({ on_list = on_list, reuse_win = true })
end

local function get_range(opts)
  -- Visual selection
  local range = {
    start = vim.api.nvim_buf_get_mark(0, "<"),
    ["end"] = vim.api.nvim_buf_get_mark(0, ">")
  }
  if opts.line1 ~= range.start[1] or
    opts.line2 ~= range["end"][1] then
    -- Supplied range inferred
    range = {
      start = { opts.line1, 0 },
      ["end"] = { opts.line2, 2147483647 }, -- Maximum line length (vi_diff.txt)
    }
  end
  return range
end

-- Documentation is missing reuse_win
local function implementation()
  vim.lsp.buf.implementation({ on_list = on_list, reuse_win = true })
end

local function references(config)
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

local function type_definition()
  vim.lsp.buf.type_definition({ on_list = on_list, reuse_win = true })
end

-- }}}

local lsp_setup = vim.api.nvim_create_augroup("lsp_setup", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
  group = lsp_setup,
  desc = "LSP buffer setup",
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    require("lbrayner.statusline").set_minor_modes(bufnr, client.name, "append")

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
  end,
})

vim.api.nvim_create_autocmd("LspDetach", {
  group = lsp_setup,
  desc = "Undo LSP buffer setup",
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    require("lbrayner.statusline").set_minor_modes(bufnr, client.name, "remove")
  end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
  group = lsp_setup,
  callback = function(args)
    local bufnr = args.buf
    if vim.api.nvim_get_current_buf() ~= bufnr then
      -- After a BufWritePost, do nothing if bufnr is not current
      return
    end
    if not vim.startswith(vim.fn.getqflist({ title = 1 }).title, "LSP Diagnostics") then
      -- Do nothing if qflist is not "LSP Diagnostics"
      return
    end
    diagnostic_setqflist({ open = false })
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

-- Commands

---@type table<string, MyCmdSubcommand>
local subcommand_tbl = {}
require("lbrayner.subcommands").create_command_and_subcommands("Lsp", subcommand_tbl, {
  desc = "Lsp and subcommands",
  range = true
})

subcommand_tbl.addWorkspaceFolder = {
  complete = require("lbrayner.subcommands").complete_filename,
  optional = function(args)
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
  ranged = function(opts)
    vim.lsp.buf.code_action({ range = get_range(opts) })
  end,
}

subcommand_tbl.declaration = {
  simple = function()
    declaration()
  end,
}

subcommand_tbl.definition = {
  simple = function()
    definition()
  end,
}

subcommand_tbl.detach = {
  simple = function()
    for _, client in ipairs(vim.lsp.get_clients()) do
      vim.lsp.buf_detach_client(0, client.id)
    end
  end,
}

subcommand_tbl.diagnostic = {
  subcommand_tbl = {
    all = {
      simple = function()
        diagnostic_qf_opts.severity = nil
        diagnostic_setqflist()
      end,
    },
    error = {
      simple = function()
        diagnostic_setqflist({ severity = vim.diagnostic.severity.ERROR })
      end,
    },
    warn = {
      simple = function()
        diagnostic_setqflist({ severity = { min = vim.diagnostic.severity.WARN } })
      end,
    },
  },
}

subcommand_tbl.documentSymbol = {
  simple = function()
    vim.lsp.buf.document_symbol()
  end,
}

subcommand_tbl.format = {
  ranged = function(opts)
    vim.lsp.buf.format({ async = true, range = get_range(opts) })
  end,
}

subcommand_tbl.hover = {
  simple = function()
    vim.lsp.buf.hover()
  end,
}

subcommand_tbl.implementation = {
  simple = function()
    implementation()
  end,
}

subcommand_tbl.listWorkspaceFolders = {
  simple = function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end,
}

subcommand_tbl.references = {
  complete = { "--no-tests" },
  optional = function(args)
    args = table.concat(args, " ")
    assert(args == "" or args == "--no-tests", string.format("Illegal arguments: %s", args))
    references({ no_tests = (args == "--no-tests") })
  end,
}

subcommand_tbl.removeWorkspaceFolder = {
  complete = require("lbrayner.subcommands").complete_filename,
  optional = function(args)
    local dir = table.concat(args, " ")
    if dir == "" then
      dir = vim.fn.getcwd()
    end
    vim.lsp.buf.remove_workspace_folder(dir)
  end,
}

subcommand_tbl.rename = {
  optional = function(args)
    local name = table.concat(args, " ")
    name = name ~= "" and name or nil
    vim.lsp.buf.rename(name)
  end,
}

subcommand_tbl.signatureHelp = {
  simple = function()
    vim.lsp.buf.signature_help()
  end,
}

subcommand_tbl.typeDefinition = {
  simple = function()
    type_definition()
  end,
}

subcommand_tbl.workspaceSymbol = {
  optional = function(args)
    local name = table.concat(args, " ")
    name = name ~= "" and name or nil
    vim.lsp.buf.workspace_symbol(name)
  end,
}
