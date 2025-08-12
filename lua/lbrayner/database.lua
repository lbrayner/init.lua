-- Backend is vim-dadbod

local get_visual_selection = require("lbrayner").get_visual_selection
local join = require("lbrayner").join
local nvim_buf_create_user_command = vim.api.nvim_buf_create_user_command
local nvim_buf_get_mark = vim.api.nvim_buf_get_mark
local nvim_buf_get_text = vim.api.nvim_buf_get_text
local nvim_buf_is_valid = vim.api.nvim_buf_is_valid
local nvim_create_augroup = vim.api.nvim_create_augroup
local nvim_create_autocmd = vim.api.nvim_create_autocmd
local nvim_create_user_command = vim.api.nvim_create_user_command

local database_access = nvim_create_augroup("database_access", { clear = true })

nvim_create_autocmd("FileType", {
  pattern = "sql",
  group = database_access,
  callback = function(args)
    local bufnr = args.buf
    vim.schedule(function()
      if not nvim_buf_is_valid(bufnr) then
        return
      end

      local bufopts = { buffer = bufnr }
      vim.keymap.set("n", "<Enter>", "<Cmd>'{,'}DB<CR>", bufopts)

      require("lbrayner.statusline").set_minor_modes(bufnr, "dadbod", "append")

      nvim_buf_create_user_command(bufnr, "DatabaseAccessClear", function()
        vim.b[bufnr].db = nil
        -- postgresql
        pcall(vim.keymap.del, "n", "<Leader>dt", bufopts)
        require("lbrayner.statusline").set_minor_modes(bufnr, "dadbod", "remove")
      end, { nargs = 0 })
    end)
  end,
})

local sql_database_access = nvim_create_augroup("sql_database_access", { clear = true })

nvim_create_autocmd("FileType", {
  pattern = "sql",
  group = sql_database_access,
  callback = function(args)
    local bufnr = args.buf
    vim.schedule(function()
      if not nvim_buf_is_valid(bufnr) then
        return
      end

      if vim.b[bufnr].db and vim.startswith(vim.b[bufnr].db, "postgresql") then
        -- Describe this object
        vim.keymap.set("n", "<Leader>dt", [[<Cmd>exe 'DB \d ' . expand("<cWORD>")<CR>]], { buffer = bufnr })
      end
    end)
  end,
})

local database_connection = nvim_create_augroup("database_connection", { clear = true })

nvim_create_autocmd({ "BufNewFile", "BufRead", }, {
  pattern = "mysql:*@*:*.sql",
  group = database_connection,
  desc = "Set up buffer MySQL database connection parameters",
  callback = function(args)
    local name = vim.fn.fnamemodify(args.match, ":t")
    vim.b.db = string.gsub(name, "^mysql:(.*)@.*:(%d+)%.sql$", "mysql://%1@localhost:%2")
  end,
})

nvim_create_autocmd({ "BufNewFile", "BufRead", }, {
  pattern = "postgresql:*@*:*.sql",
  group = database_connection,
  desc = "Set up buffer PostgreSQL database connection parameters",
  callback = function(args)
    local name = vim.fn.fnamemodify(args.match, ":t")
    vim.b.db = string.gsub(name, "^postgresql:(.*)@.*:(%d+)%.sql$", "postgresql://%1@localhost:%2")
  end,
})

nvim_create_autocmd({ "BufNewFile", "BufRead", }, {
  pattern = "sqlserver:*:*@*:*.sql",
  group = database_connection,
  desc = "Set up buffer SQL Server database connection parameters",
  callback = function(args)
    local name = vim.fn.fnamemodify(args.match, ":t")
    local user, pwd_var, host, port = string.match(name, "^sqlserver:(.*):(.*)@(.*):(%d+)%.sql$")
    local password = pwd_var ~= "" and os.getenv(pwd_var) or ""
    vim.b.db = string.format(
      "sqlserver://%s@%s:%s?password=%s&trustServerCertificate=true",
      user, host, port, vim.uri_encode(password)
    )
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
        vim.fn.substitute(
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
