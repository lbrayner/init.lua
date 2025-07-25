local join = require("lbrayner").join

local function get_range(opts)
  local visual_selection = {
    start = vim.api.nvim_buf_get_mark(0, "<"),
    ["end"] = vim.api.nvim_buf_get_mark(0, ">")
  }

  if opts.line1 ~= visual_selection.start[1] or
    opts.line2 ~= visual_selection["end"][1] then
    -- Supplied range inferred
    return {
      start = { opts.line1, 0 },
      ["end"] = { opts.line2, 2147483647 }, -- Maximum line length (vi_diff.txt)
    }
  end

  return visual_selection
end

---@type table<string, MyCmdSubcommand>
local subcommand_tbl = {}
require("lbrayner.subcommands").create_user_command_and_subcommands("Lsp", subcommand_tbl, {
  bar = true,
  desc = "LSP client commands",
  range = true
})

subcommand_tbl.addWorkspaceFolder = {
  complete = require("lbrayner.subcommands").complete_filename,
  optional = function(opts)
    local dir = join(opts.args)
    if dir == "" then
      dir = vim.fn.getcwd()
    else
      dir = vim.fn.fnamemodify(dir, ":p") -- In case ".", "..", etc. are supplied
    end
    vim.lsp.buf.add_workspace_folder(dir)
  end,
}

subcommand_tbl.codeAction = {
  ranged = true,
  simple = function(opts)
    vim.lsp.buf.code_action({ range = get_range(opts) })
  end,
}

subcommand_tbl.declaration = {
  simple = require("lbrayner.lsp").declaration,
}

subcommand_tbl.definition = {
  simple = require("lbrayner.lsp").definition,
}

subcommand_tbl.detach = {
  simple = function()
    for _, client in ipairs(vim.lsp.get_clients()) do
      vim.lsp.buf_detach_client(0, client.id)
    end
  end,
}

subcommand_tbl.diagnostic = {
  complete = { "--error", "--warn" },
  optional = function(opts)
    local args = opts.args

    assert(
      vim.tbl_isempty(args) or #args == 1,
      string.format("Illegal arguments: %s", join(args))
    )

    local _, arg = next(args)

    if not arg then
      require("lbrayner.lsp").diagnostic_setqflist({ severity = { min = vim.diagnostic.severity.HINT } })
      return
    end

    assert(
      vim.list_contains(opts.subcommand.complete, arg),
      string.format("Illegal arguments: %s", join(args))
    )

    if arg == "--error" then
      require("lbrayner.lsp").diagnostic_setqflist({ severity = vim.diagnostic.severity.ERROR })
    end

    if arg == "--warn" then
      require("lbrayner.lsp").diagnostic_setqflist({ severity = { min = vim.diagnostic.severity.WARN } })
    end
  end,
}

subcommand_tbl.documentSymbol = {
  simple = function() vim.lsp.buf.document_symbol() end,
}

subcommand_tbl.format = {
  ranged = true,
  simple = function(opts)
    vim.lsp.buf.format({ async = true, range = get_range(opts) })
  end,
}

subcommand_tbl.hover = {
  simple = require("lbrayner.lsp").hover,
}

subcommand_tbl.implementation = {
  simple = require("lbrayner.lsp").implementation,
}

subcommand_tbl.listWorkspaceFolders = {
  simple = function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end,
}

subcommand_tbl.references = {
  complete = { "--no-tests" },
  optional = function(opts)
    local args = join(opts.args)
    assert(args == "" or args == "--no-tests", string.format("Illegal arguments: %s", args))
    require("lbrayner.lsp").references({ no_tests = (args == "--no-tests") })
  end,
}

subcommand_tbl.removeWorkspaceFolder = {
  complete = require("lbrayner.subcommands").complete_filename,
  optional = function(opts)
    local dir = join(opts.args)
    if dir == "" then
      dir = vim.fn.getcwd()
    end
    vim.lsp.buf.remove_workspace_folder(dir)
  end,
}

subcommand_tbl.rename = {
  optional = function(opts)
    local name = join(opts.args)
    name = name ~= "" and name or nil
    vim.lsp.buf.rename(name)
  end,
}

subcommand_tbl.typeDefinition = {
  simple = require("lbrayner.lsp").type_definition,
}

subcommand_tbl.workspaceSymbol = {
  optional = function(opts)
    local name = join(opts.args)
    name = name ~= "" and name or nil
    vim.lsp.buf.workspace_symbol(name)
  end,
}
