-- vim: fdm=marker
-- From vim-ripgrep (https://github.com/lbrayner/vim-ripgrep)

local M = {}

local concat = table.concat
local format = string.format
local get_visual_selection = require("lbrayner").get_visual_selection
local join = require("lbrayner").join
local notify = vim.notify
local nvim_buf_get_mark = vim.api.nvim_buf_get_mark
local nvim_buf_get_name = vim.api.nvim_buf_get_name

local function rg(args, opts) -- {{{
  if vim.fn.executable("rg") == 0 then
    error("Rg: 'rg' not executable.")
  end

  local cmd, cmdopts = "rg --engine=auto --vimgrep --sort path", {}
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
    cmd = join({ concat({ "RIPGREP_CONFIG_PATH=", opts.config_path }), cmd })
  end

  if opts.places and vim.uv.fs_stat(opts.places) then
    cmd = join({ "xargs -d\\\\n", cmd, "<", opts.places })
  end

  if vim.o.ignorecase then
    table.insert(cmdopts, "-i")
  end

  if vim.o.smartcase then
    table.insert(cmdopts, "-S")
  end

  cmd = join({ cmd, join(cmdopts), args })
  local title, qfid = opts.title or cmd

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
        notify(format("No match found for “%s”.", args))
      elseif obj.code > 1 then
        if qfid then
          qflist = getqf({ id = 0 })

          if qfid == qflist.id then cclose() end
        end

        notify(format(
          "Error searching for “%s”.%s",
          args, obj.stderr and obj.stderr ~= "" and concat({ "\n", obj.stderr }) or ""
        ))
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

    if opts.places and type(opts.places) ~= "string" then
      return false, "'places' must be a string"
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
    local function get_context()
      local context = vim.fn.getqflist({ context = 1 }).context

      if vim.tbl_get(context, "ripgrep", "args") then
        return context
      else
        error("Could not find a ripgrep search context.")
      end
    end

    local args, count, rgopts = opts.args, opts.count, { config_path = config_path }

    if count == 0 then -- :0Rg
      local context = get_context()
      -- :0Rg juxtaposes last text with new text
      args = join({ context.ripgrep.args, args })
    elseif count == 1 then -- :1Rg
      -- :1Rg searches files from the previous search
      local _, names = get_context(), {}

      for _, qfitem in ipairs(vim.fn.getqflist()) do
        if qfitem.bufnr > 0 then
          names[nvim_buf_get_name(qfitem.bufnr)] = true
        end
      end

      rgopts.places = os.tmpname()
      local file = io.open(rgopts.places, "w")

      names = vim.tbl_keys(names)
      table.sort(names)

      for _, name in ipairs(names) do
        file:write(concat({ name, "\n" }))
      end

      file:close()
    elseif count > 0 then -- :'<,'>Rg
      -- https://neovim.discourse.group/t/function-that-return-visually-selected-text/1601
      local success, result = get_visual_selection(opts)

      if not success then
        if result == 1 then
          notify("Line range not allowed, only visual selection.")
        elseif result == 2 then
          notify("Visual selection pattern cannot span multiple lines.")
        end

        return
      end

      args = join({ "-s -F -e", vim.fn.shellescape(result[1]), args })
    end

    M.rg(args, rgopts)
  end, { complete = "file", nargs = "*", range = -1 })
end

M.user_command_with_config_path("Rg")
M.user_command_with_config_path("RgNoTests", ".ripgreprc-no-tests")
M.user_command_with_config_path("RgTests", ".ripgreprc-tests")

vim.keymap.set("ca", "Rb", [[Rg -s -e'\b''\b'<Left><Left><Left><Left>]])
vim.keymap.set("ca", "Rg", "Rg -e")
vim.keymap.set("ca", "Rw", [[Rg -s -e'\b'<C-R><C-W>'\b']])

return M
