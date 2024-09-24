-- Backend is vim-dadbod

local database_access = vim.api.nvim_create_augroup("database_access", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "redis", "sql" },
  group = database_access,
  callback = function(args)
    local bufnr = args.buf
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(bufnr) then
        return
      end

      local bufopts = { buffer = bufnr }
      vim.keymap.set("n", "<C-Return>", "<Cmd>'{,'}DB<CR>", bufopts)
      vim.keymap.set("n", "<C-kEnter>", "<Cmd>'{,'}DB<CR>", bufopts)

      if vim.b[bufnr].db then
        vim.b[bufnr].Statusline_custom_rightline = "%9*dadbod%* "
        vim.b[bufnr].Statusline_custom_mod_rightline = "%9*dadbod%* "
      end

      vim.api.nvim_buf_create_user_command(bufnr, "DatabaseAccessClear", function()
        vim.b[bufnr].db = nil
        -- postgresql
        pcall(vim.keymap.del, "n", "<Leader>dt", bufopts)
        -- statusline
        vim.b[bufnr].Statusline_custom_rightline = nil
        vim.b[bufnr].Statusline_custom_mod_rightline = nil
        vim.api.nvim_exec_autocmds("User", { modeline = false, pattern = "CustomStatusline" })
      end, { nargs = 0 })
    end)
  end,
})

local sql_database_access = vim.api.nvim_create_augroup("sql_database_access", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "sql",
  group = sql_database_access,
  callback = function(args)
    local bufnr = args.buf
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(bufnr) then
        return
      end

      if vim.b[bufnr].db and vim.startswith(vim.b[bufnr].db, "postgresql") then
        -- Describe this object
        vim.keymap.set("n", "<Leader>dt", [[<Cmd>exe 'DB \d ' . expand("<cWORD>")<CR>]], { buffer = bufnr })
      end
    end)
  end,
})

local database_connection = vim.api.nvim_create_augroup("database_connection", { clear = true })

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead", }, {
  pattern = "postgresql:*@*:*.sql",
  group = database_connection,
  desc = "Set up buffer SQL database connection parameters",
  callback = function(args)
    local name = vim.fn.fnamemodify(args.match, ":t")
    vim.b.db = string.gsub(name, "^postgresql:(.*)@.*:(%d+)%.sql$", "postgresql://%1@localhost:%2")
  end,
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead", }, {
  pattern = "redis:*:*.redis",
  group = database_connection,
  desc = "Set up buffer Redis database connection parameters",
  callback = function(args)
    local name = vim.fn.fnamemodify(args.match, ":t")
    vim.b.db = string.gsub(name, "^redis:.*:(%d+)%.redis$", "redis://:%1")
  end,
})
