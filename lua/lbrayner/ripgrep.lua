-- vim: fdm=marker
-- From vim-ripgrep (https://github.com/lbrayner/vim-ripgrep)

local M = {}

local function rg(args, opts) -- {{{
  opts = opts or {}
  assert(type(args) == "string", "'args' must be a string")
  assert(
    not opts.config_path or type(opts.config_path) == "string",
    "'config_path' must be a string"
  )
  assert(
    not opts.loclist or type(opts.loclist) == "boolean", "'loclist' must be a boolean"
  )

  local rgopts = {}

  if vim.o.ignorecase then
    table.insert(rgopts, "-i")
  end

  if vim.o.smartcase then
    table.insert(rgopts, "-S")
  end

  if not vim.startswith(vim.o.grepprg, "rg") and
    not string.find(vim.o.grepprg, "^RIPGREP_CONFIG_PATH=.* rg") then
    error("Rg: 'grepprg' not correctly set.")
  end

  if not vim.fn.executable("rg") then
    error("Rg: 'rg' not executable.")
  end

  local cmd = table.concat({ "rg --engine=auto --vimgrep --sort path", unpack(rgopts), args }, " ")
  print("cmd", vim.inspect(cmd)) -- TODO debug

  vim.system(
    { "sh", "-c", cmd },
    {
      cwd = vim.fn.getcwd(),
      stdout = function(err, data)
        assert(not err, err)
        print("data", vim.inspect(data)) -- TODO debug
      end,
      text = true,
    },
    vim.schedule_wrap(function(obj)
      if obj.code == 1 then
        vim.notify(string.format("No match found for “%s”.", args))
      elseif obj.code > 1 then
        vim.notify(string.format(
          "Error searching for “%s”. Unmatched quotes? Check your command.", args
        ))
      end
    end)
  )
end -- }}}

function M.lrg(args, config_path)
  return rg(args, { config_path = config_path, loclist = true })
end

function M.rg(args, config_path)
  return rg(args, { config_path = config_path })
end

function M.user_command_with_config_path(command_name, config_path)
  vim.api.nvim_create_user_command(command_name, function(opts)
    -- print("opts", vim.inspect(opts)) -- TODO debug
    local args = opts.args
    local count = opts.count
    local line1 = opts.line1
    local line2 = opts.line2

    if count == 0 then -- :0Rg
      local context = vim.fn.getqflist({ context = 1 }).context

      if vim.tbl_get(context, "ripgrep", "args") then
        -- :0Rg performs a search with the last text juxtaposed with the new text
        args = vim.trim(table.concat({ context.ripgrep.args, args }, " "))
      else
        vim.notify("Could not find a ripgrep search context.")
        return
      end
    elseif count > 0 then -- :'<,'>Rg
      -- https://neovim.discourse.group/t/function-that-return-visually-selected-text/1601
      local pos_start = vim.api.nvim_buf_get_mark(0, "<")
      local pos_end = vim.api.nvim_buf_get_mark(0, ">")

      if line1 ~= pos_start[1] or line2 ~= pos_end[1] then
        vim.notify("Line range not allowed, only visual selection.")
        return
      end

      if pos_start[1] ~= pos_end[1] then
        vim.notify("Visual selection pattern cannot span multiple lines.")
        return
      end

      local start_row = pos_start[1] - 1
      local start_col = pos_start[2]
      local end_row = pos_end[1] - 1
      local end_col = pos_end[2] + 1
      local visual_selection = vim.api.nvim_buf_get_text(0, start_row, start_col, end_row, end_col, {})[1]

      args = vim.trim(table.concat({
        string.format("-s -F -e %s", vim.fn.shellescape(visual_selection)),
        args
      }, " "))
    end

    M.rg(args, config_path)
  end, { complete = "file", nargs = "*", range = -1 })
end

M.user_command_with_config_path("Rg")
M.user_command_with_config_path("RgNoTests", ".ripgreprc-no-tests")
M.user_command_with_config_path("RgTests", ".ripgreprc-tests")

vim.keymap.set("ca", "Rb", [[Rg -s -e'\b''\b'<Left><Left><Left><Left>]])
vim.keymap.set("ca", "Rg", "Rg -e")
vim.keymap.set("ca", "Rt", [[RgTests -s -e'\b''\b'<Left><Left><Left><Left>]])
vim.keymap.set("ca", "Rw", [[Rg -s -e'\b'<C-R><C-W>'\b']])

return M
