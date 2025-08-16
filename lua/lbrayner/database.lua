-- vim: fdm=marker

-- Backend is vim-dadbod

local M = {}

-- Local variables -- {{{

local cmd = vim.cmd
local fnamemodify = vim.fn.fnamemodify
local format = string.format
local get_visual_selection = require("lbrayner").get_visual_selection
local getenv = os.getenv
local gsub = string.gsub -- TODO remove
local join = require("lbrayner").join
local match = string.match
local nvim_buf_create_user_command = vim.api.nvim_buf_create_user_command
local nvim_buf_del_user_command = vim.api.nvim_buf_del_user_command
local nvim_buf_get_mark = vim.api.nvim_buf_get_mark
local nvim_buf_get_text = vim.api.nvim_buf_get_text
local nvim_buf_is_valid = vim.api.nvim_buf_is_valid
local nvim_create_augroup = vim.api.nvim_create_augroup
local nvim_create_autocmd = vim.api.nvim_create_autocmd
local nvim_create_user_command = vim.api.nvim_create_user_command
local nvim_get_current_buf = vim.api.nvim_get_current_buf
local set_minor_modes = require("lbrayner.statusline").set_minor_modes
local startswith = vim.startswith
local substitute = vim.fn.substitute
local uri_encode = vim.uri_encode
local vim_keymap_del = vim.keymap.del
local vim_keymap_set = vim.keymap.set

-- }}}

-- NoSQL databases
function M.set_up_database_access(bufnr)
  bufnr = bufnr or nvim_get_current_buf()
  local bufopts = { buffer = bufnr }
  vim_keymap_set("n", "<Enter>", "<Cmd>'{,'}DB<CR>", bufopts)

  set_minor_modes(bufnr, "dadbod", "append")

  nvim_buf_create_user_command(bufnr, "DatabaseAccessClear", function()
    pcall(vim_keymap_del, "n", "<Enter>", bufopts)
    set_minor_modes(bufnr, "dadbod", "remove")
    vim.b[bufnr].db = nil

    -- postgresql, sqlserver
    pcall(nvim_buf_del_user_command, bufnr, "Describe")
  end, { nargs = 0 })
end

function M.set_up_sql_database_access(bufnr)
  bufnr = bufnr or nvim_get_current_buf()

  M.set_up_database_access(bufnr)

  local db = vim.b[bufnr].db

  if db and type(db) == "string" then
    if startswith(db, "postgresql") then
      nvim_buf_create_user_command(bufnr, "Describe", function()
        -- Describe this object
        cmd([[exe 'DB \d ' . expand("<cWORD>")]])
      end, { nargs = 0 })
    elseif startswith(db, "sqlserver") then
      nvim_buf_create_user_command(bufnr, "Describe", function()
        -- Describe this object
        cmd([[exe "DB exec sp_help '" . expand("<cWORD>") . "'"]])
      end, { nargs = 0 })
    end
  end
end

local database_connection = nvim_create_augroup("database_connection", { clear = true })

nvim_create_autocmd({ "BufNewFile", "BufRead", }, {
  pattern = "mysql:*:*@*:*.sql",
  group = database_connection,
  desc = "Set up buffer MySQL database connection parameters",
  callback = function(args)
    local name = fnamemodify(args.match, ":t")
    local user, pwd_var, host, port = match(
      name, "^mysql:(.*):(.*)@(.*):(%d+)%.sql$"
    )
    local password = pwd_var ~= "" and getenv(pwd_var) or ""

    vim.b.db = format(
      "mysql://%s@%s:%s?password=%s",
      user, host, port, uri_encode(password)
    )

    M.set_up_sql_database_access()
  end,
})

nvim_create_autocmd({ "BufNewFile", "BufRead", }, {
  pattern = "postgresql:*@*:*:*.sql",
  group = database_connection,
  desc = "Set up buffer PostgreSQL database connection parameters",
  callback = function(args)
    local name = fnamemodify(args.match, ":t")
    local user, host, port, database = match(
      name, "^postgresql:(.+)@(.+):(%d+):(.*)%.sql$"
    )

    -- psql recommends .pgpass for passwords
    vim.b.db = format(
      "postgresql://%s@%s:%s/%s", user, host, port, database
    )

    M.set_up_sql_database_access()
  end,
})

nvim_create_autocmd({ "BufNewFile", "BufRead", }, {
  pattern = "sqlserver:*:*@*:*:*.sql",
  group = database_connection,
  desc = "Set up buffer SQL Server database connection parameters",
  callback = function(args)
    local name = fnamemodify(args.match, ":t")
    local user, pwd_var, host, port, database = match(
      name, "^sqlserver:(.+):(.+)@(.+):(%d+):(.*)%.sql$"
    )
    local password = pwd_var ~= "" and getenv(pwd_var) or ""

    vim.b.db = format(
      "sqlserver://%s@%s:%s/%s?password=%s&trustServerCertificate=true",
      user, host, port, database, uri_encode(password)
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

      local success, result = get_visual_selection(opts, { multi_line = true })

      if success then
        args = join({ join(result), args })
        count = -1 -- else vim-dadbod will add visual linewise selection on top of args
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
