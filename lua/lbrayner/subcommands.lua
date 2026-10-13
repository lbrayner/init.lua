-- https://github.com/nvim-neorocks/nvim-best-practices

local concat = table.concat
local glob = vim.fn.glob
local iter = vim.iter
local list_slice = vim.list_slice
local notify = vim.notify
local nvim_create_user_command = vim.api.nvim_create_user_command
local substitute = vim.fn.substitute
local tbl_extend = vim.tbl_extend
local tbl_get = vim.tbl_get
local tbl_isempty = vim.tbl_isempty
local tbl_keys = vim.tbl_keys

local M = {}

function M.complete_filename(lead)
  return glob(concat({ lead, "*" }), 1, 1)
end

local function main_cmd(name, subcommand_tbl)
  return function(opts)
    (function (subcommand_tbl)
      local fargs = opts.fargs

      while tbl_get(subcommand_tbl, fargs[1], "subcommand_tbl") and
        type(subcommand_tbl[fargs[1]].subcommand_tbl) == "table" do
        subcommand_tbl = subcommand_tbl[fargs[1]].subcommand_tbl
        table.remove(fargs, 1)
      end

      local subcommand_key = fargs[1]
      local subcommand = subcommand_tbl[subcommand_key]

      if not subcommand then
        notify(
          concat({ name, ": Unknown command: ", subcommand_key }),
          vim.log.levels.ERROR
        )
        return
      end

      opts.args = #fargs > 1 and list_slice(fargs, 2, #fargs) or {}
      opts.subcommand = subcommand

      if subcommand.simple and type(subcommand.simple) == "function" then
        assert(
          tbl_isempty(opts.args),
          string.format("Trailing characters: %s", table.concat(opts.args, " "))
        )
        assert(subcommand.ranged or opts.range == 0, "No range allowed")

        subcommand.simple(opts)
      elseif subcommand.optional and type(subcommand.optional) == "function" then
        assert(subcommand.ranged or opts.range == 0, "No range allowed")

        subcommand.optional(opts)
      else
        subcommand.impl(opts)
      end
    end)(subcommand_tbl)
  end
end

local function smart_complete(lead, options)
  if not lead:find("%u") then
    return iter(options)
    :filter(function(option)
      return option:lower():find(lead:lower(), 1, true) ~= nil
    end)
    :totable()
  else
    return iter(options)
    :filter(function(option)
      return option:find(lead, 1, true) ~= nil
    end)
    :totable()
  end
end

function M.create_user_command_and_subcommands(name, subcommand_tbl, opts)
  opts = opts or {}

  assert(name:match("^%u%a+$"), "Bad argument; 'name' must a capitalized word.")
  assert(type(subcommand_tbl) == "table", "'subcommand_tbl' must be a table")
  assert(type(opts) == "table", "'opts' must be a table")

  opts = tbl_extend("keep", {
    nargs = "+",
    complete = function(arg_lead, cmdline, _)
      local arguments = substitute(
        cmdline,
        concat({
          [[.*\%(\s*|\s*\)\?]], name, "[!]\\?\\(\\s\\+[^[:blank:]]*\\)\\%(\\s*|.*\\)\\?"
        }),
        [[\1]],
        ""
      )

      if arguments == cmdline then return end

      arg_lead = substitute(
        arg_lead,
        "^\\([^[:blank:]]\\+\\)\\s.*",
        [[\1]],
        ""
      )

      return (function(subcommand_tbl)
        -- Support nested subcommand tables
        local subcommand_key = (function()
          for w in string.gmatch(arguments, "%s+(%w+)") do
            if tbl_get(subcommand_tbl, w, "subcommand_tbl") and
              type(subcommand_tbl[w].subcommand_tbl) == "table" then
              subcommand_tbl = subcommand_tbl[w].subcommand_tbl
            else
              return subcommand_tbl[w] and w or nil
            end
          end
        end)()

        if not subcommand_key then
          -- Filter subcommands that match
          local candidates = smart_complete(arg_lead, tbl_keys(subcommand_tbl))
          table.sort(candidates)
          return candidates
        elseif arg_lead and tbl_get(subcommand_tbl, subcommand_key, "complete") then
          if type(subcommand_tbl[subcommand_key].complete) == "table" then
            local candidates = smart_complete(
              arg_lead, subcommand_tbl[subcommand_key].complete
            )
            table.sort(candidates)
            return candidates
          end

          return subcommand_tbl[subcommand_key].complete(arg_lead)
        end
      end)(subcommand_tbl)
    end,
  }, opts)

  nvim_create_user_command(name, main_cmd(name, subcommand_tbl), opts)
end

return M
