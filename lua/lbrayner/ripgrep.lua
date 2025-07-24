-- vim: fdm=marker
-- From vim-ripgrep (https://github.com/lbrayner/vim-ripgrep)

local M = {}

local join = require("lbrayner").join

local function rg(args, opts) -- {{{
  if vim.fn.executable("rg") == 0 then
    error("Rg: 'rg' not executable.")
  end

  local grep, rgopts = "rg --engine=auto --vimgrep --sort path", {}
  local cclose, copen, getqf, setqf

  if opts.loclist then
    cclose, copen = vim.cmd.lclose, vim.cmd.lopen

    getqf = function(...)
      return vim.fn.getloclist(opts.loclist, ...)
    end

    setqf = function(...)
      return vim.fn.setloclist(opts.loclist, ...)
    end
  else
    cclose, copen = vim.cmd.cclose, vim.cmd.copen
    getqf, setqf = vim.fn.getqflist, vim.fn.setqflist
  end

  if opts.config_path and vim.uv.fs_stat(opts.config_path) then
    grep = join({ "RIPGREP_CONFIG_PATH=" .. opts.config_path, grep })
  end

  if vim.o.ignorecase then
    table.insert(rgopts, "-i")
  end

  if vim.o.smartcase then
    table.insert(rgopts, "-S")
  end

  local cmd, qfid = join({ grep, join(rgopts), args })
  local title = opts.title or cmd

  vim.system(
    { "sh", "-c", cmd },
    {
      cwd = vim.fn.getcwd(),
      stdout = vim.schedule_wrap(function(err, data)
        assert(not err, err)

        local qflist

        if not data then
          if qfid then
            setqf({}, "a", { id = qfid, title = title })
            qflist = getqf({ id = 0 })

            if qfid == qflist.id then copen() end
          end

          return
        end

        local lines = vim.split(data, "\n")
        local last = lines[#lines]

        if last == "" then
          table.remove(lines) -- Pop the top
        end

        local action = " "
        qflist = getqf({ id = qfid, title = 1 })

        if qfid and qfid == qflist.id then
          action = "a"
        elseif title == qflist.title then
          action = "u"
        end

        setqf({}, action, {
          efm = "%f:%l:%c:%m",
          context = { ripgrep = { args = args } },
          lines = lines,
          title = join({ title, "" }),
        })

        if not qfid then
          qflist = getqf({ id = 0 })
          qfid = qflist.id
        end
      end),
      text = true,
    },
    vim.schedule_wrap(function(obj)
      if opts.on_exit then
        opts.on_exit(obj, args, qfid)
      elseif obj.code == 1 then
        vim.notify(string.format("No match found for “%s”.", args))
      elseif obj.code > 1 then
        if qfid then
          qflist = getqf({ id = 0 })

          if qfid == qflist.id then cclose() end
        end

        vim.notify(string.format(
          "Error searching for “%s”. Unmatched quotes? Check your command.", args
        ))
        -- else add to title (ERROR)
      end
    end)
  )
end -- }}}

function M.rg(args, opts)
  assert(type(args) == "string", "'args' must be a string")
  vim.validate("opts", opts, function(opts)
    if type(opts) ~= "table" then
      return false, "'opts' must be a table"
    end

    if opts.config_path and type(opts.config_path) ~= "string" then
      return false, "'config_path' must be a string"
    end

    if opts.loclist and type(opts.loclist) ~= "number" then
      return false, "'loclist' must be a number (winid)"
    end

    if opts.on_exit and type(opts.on_exit) ~= "function" then
      return false, "'on_exit' must be a function"
    end

    if opts.title and type(opts.title) ~= "string" then
      return false, "'title' must be a string"
    end

    return true
  end, true, "'opts' table")

  opts = opts or {}

  return rg(args, opts)
end

function M.user_command_with_config_path(command_name, config_path)
  vim.api.nvim_create_user_command(command_name, function(opts)
    local args = opts.args
    local count = opts.count
    local line1 = opts.line1
    local line2 = opts.line2

    if count == 0 then -- :0Rg
      local context = vim.fn.getqflist({ context = 1 }).context

      if vim.tbl_get(context, "ripgrep", "args") then
        -- :0Rg performs a search with the last text juxtaposed with the new text
        args = join({ context.ripgrep.args, args })
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

      args = join({ "-s -F -e", vim.fn.shellescape(visual_selection), args })
    end

    M.rg(args, { config_path = config_path })
  end, { complete = "file", nargs = "*", range = -1 })
end

M.user_command_with_config_path("Rg")
M.user_command_with_config_path("RgNoTests", ".ripgreprc-no-tests")
M.user_command_with_config_path("RgTests", ".ripgreprc-tests")

vim.keymap.set("ca", "Rb", [[Rg -s -e'\b''\b'<Left><Left><Left><Left>]])
vim.keymap.set("ca", "Rg", "Rg -e")
vim.keymap.set("ca", "Rw", [[Rg -s -e'\b'<C-R><C-W>'\b']])

return M
