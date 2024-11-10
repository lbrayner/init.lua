-- https://github.com/nvim-neorocks/nvim-best-practices

local M = {}

function M.complete_filename(lead)
  return vim.fn.glob(lead .. "*", 1, 1)
end

local function main_cmd(name, subcommand_tbl)
  ---@param opts table :h lua-guide-commands-create
  return function(opts)
    local fargs = opts.fargs
    while vim.tbl_get(subcommand_tbl, fargs[1], "subcommand_tbl") and
      type(subcommand_tbl[fargs[1]].subcommand_tbl) == "table" do
      subcommand_tbl = subcommand_tbl[fargs[1]].subcommand_tbl
      table.remove(fargs, 1)
    end
    local subcommand_key = fargs[1]
    -- Get the subcommand's arguments, if any
    local args = #fargs > 1 and vim.list_slice(fargs, 2, #fargs) or {}
    local subcommand = subcommand_tbl[subcommand_key]
    if not subcommand then
      vim.notify(name .. ": Unknown command: " .. subcommand_key, vim.log.levels.ERROR)
      return
    end
    -- Invoke the subcommand
    if subcommand.simple and type(subcommand.simple) == "function" then
      assert(vim.tbl_isempty(args), string.format("Trailing characters: %s", table.concat(args, " ")))
      subcommand.simple(opts)
    else
      subcommand.impl(args, opts)
    end
  end
end

function M.create_command_and_subcommands(name, subcommand_tbl, opts)
  opts = opts or {}
  assert(name:match("^%u%a+$"), "Bad argument; 'name' must a capitalized word.")
  assert(type(subcommand_tbl) == "table", "'subcommand_tbl' must be a table")
  assert(type(opts) == "table", "'opts' must be a table")
  vim.api.nvim_create_user_command(name, main_cmd(name, subcommand_tbl), vim.tbl_extend("keep", {
    nargs = "+",
    complete = function(arg_lead, cmdline, _)
      -- Check if cmdline is a subcommand
      local subcommands = cmdline:match("^['<,'>]*" .. name .. "[!]?(%s+.*)")
      if not subcommands then
        return
      end
      -- Get the subcommand.
      local subcmd_key
      (function()
        -- Support nested subcommand tables
        for w in string.gmatch(subcommands, "%s+(%S+)") do
          if vim.tbl_get(subcommand_tbl, w, "subcommand_tbl") and
            type(subcommand_tbl[w].subcommand_tbl) == "table" then
            subcommand_tbl = subcommand_tbl[w].subcommand_tbl
            subcmd_key = w
          else
            return
          end
        end
      end)()
      if subcmd_key
        and arg_lead
        and subcommand_tbl[subcmd_key]
        and subcommand_tbl[subcmd_key].complete then
        -- The subcommand has completions. Return them.
        return subcommand_tbl[subcmd_key].complete(arg_lead)
      end
      -- Filter subcommands that match
      local subcommand_keys = vim.tbl_keys(subcommand_tbl)
      local candidates = vim.iter(subcommand_keys)
      :filter(function(key)
        return key:find(arg_lead) ~= nil
      end)
      :totable()
      table.sort(candidates)
      return candidates
    end,
  }, opts))
end

return M
