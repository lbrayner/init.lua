-- vim: fdm=marker

-- Backend is vim-dadbod

local M = {}

-- Local variables -- {{{

local fnamemodify = vim.fn.fnamemodify
local format = string.format
local get_visual_selection = require("lbrayner").get_visual_selection
local getenv = os.getenv
local gsub = string.gsub -- TODO remove
local join = require("lbrayner").join
local match = string.match
local nvim_buf_create_user_command = vim.api.nvim_buf_create_user_command
local nvim_buf_get_mark = vim.api.nvim_buf_get_mark
local nvim_buf_get_text = vim.api.nvim_buf_get_text
local nvim_buf_is_valid = vim.api.nvim_buf_is_valid
local nvim_create_augroup = vim.api.nvim_create_augroup
local nvim_create_autocmd = vim.api.nvim_create_autocmd
local nvim_create_user_command = vim.api.nvim_create_user_command
local nvim_get_current_buf = vim.api.nvim_get_current_buf
local set_minor_modes = require("lbrayner.statusline").set_minor_modes
local substitute = vim.fn.substitute
local uri_encode = vim.uri_encode
local vim_keymap_del = vim.keymap.del
local vim_keymap_set = vim.keymap.set
local startswith = vim.startswith

-- }}}

-- NoSQL databases
function M.set_up_database_access(bufnr)
  bufnr = bufnr or nvim_get_current_buf()
  local bufopts = { buffer = bufnr }
  vim_keymap_set("n", "<Enter>", "<Cmd>'{,'}DB<CR>", bufopts)

  set_minor_modes(bufnr, "dadbod", "append")

  nvim_buf_create_user_command(bufnr, "DatabaseAccessClear", function()
    vim.b[bufnr].db = nil
    -- postgresql
    pcall(vim_keymap_del, "n", "<Leader>dt", bufopts)
    set_minor_modes(bufnr, "dadbod", "remove")
  end, { nargs = 0 })
end

function M.set_up_sql_database_access(bufnr)
  bufnr = bufnr or nvim_get_current_buf()

  M.set_up_database_access(bufnr)

  if vim.b[bufnr].db and startswith(vim.b[bufnr].db, "postgresql") then
    -- Describe this object
    vim_keymap_set("n", "<Leader>dt", [[<Cmd>exe 'DB \d ' . expand("<cWORD>")<CR>]], { buffer = bufnr })
  end
end

local database_connection = nvim_create_augroup("database_connection", { clear = true })

nvim_create_autocmd({ "BufNewFile", "BufRead", }, {
  pattern = "mysql:*:*@*:*.sql",
  group = database_connection,
  desc = "Set up buffer MySQL database connection parameters",
  callback = function(args)
    local name = fnamemodify(args.match, ":t")
    local user, pwd_var, host, port = match(name, "^mysql:(.*):(.*)@(.*):(%d+)%.sql$")
    local password = pwd_var ~= "" and getenv(pwd_var) or ""

    vim.b.db = format(
      "mysql://%s@%s:%s?password=%s",
      user, host, port, uri_encode(password)
    )

    M.set_up_sql_database_access()
  end,
})

nvim_create_autocmd({ "BufNewFile", "BufRead", }, {
  pattern = "postgresql:*@*:*.sql",
  group = database_connection,
  desc = "Set up buffer PostgreSQL database connection parameters",
  callback = function(args)
    local name = fnamemodify(args.match, ":t")
    local user, host, port = match(name, "^postgresql:(.*)@(.*):(%d+)%.sql$")

    -- psql derives password from .pgpass
    vim.b.db = format(
      "postgresql://%s@%s:%s", user, host, port
    )

    M.set_up_sql_database_access()
  end,
})

nvim_create_autocmd({ "BufNewFile", "BufRead", }, {
  pattern = "sqlserver:*:*@*:*.sql",
  group = database_connection,
  desc = "Set up buffer SQL Server database connection parameters",
  callback = function(args)
    local name = fnamemodify(args.match, ":t")
    local user, pwd_var, host, port = match(name, "^sqlserver:(.*):(.*)@(.*):(%d+)%.sql$")
    local password = pwd_var ~= "" and getenv(pwd_var) or ""

    vim.b.db = format(
      "sqlserver://%s@%s:%s?password=%s&trustServerCertificate=true",
      user, host, port, uri_encode(password)
    )

    M.set_up_sql_database_access()
  end,
})

-- Redefine DB
nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    nvim_create_user_command("DB", function(opts)
      local args = opts.args
      local count = opts.count

      if count > 0 then
        local success, result = get_visual_selection(opts, { multi_line = true })

        if success then
          args = join({ join(result), args })
          count = -1 -- else vim-dadbod will add visual linewise selection on top of args
        end
      end

      vim.fn["db#execute_command"](
        "<mods>", opts.bang and 1 or 0, opts.line1, count,
        substitute(
          args, "^[al]:\\w\\+\\>\\ze\\s*\\%($\\|[^[:space:]=]\\)",
          "\\=eval(submatch(0))", ""
        )
      )
    end, {
    desc = "Make DB support true visual selection (not linewise)",
    bang = true, complete = "custom,db#command_complete", nargs = "?", range = -1
  })
  end,
})

return M
