local terminal_setup = vim.api.nvim_create_augroup("terminal_setup", { clear = true })

vim.api.nvim_create_autocmd("TermOpen", {
  group = terminal_setup,
  desc = "Terminal filetype",
  callback = function()
    vim.bo.filetype = "terminal"
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "terminal",
  group = terminal_setup,
  desc = "Fix terminal title and set keymaps",
  callback = function(args)
    local bufnr = args.buf

    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(bufnr) then
        return
      end

      if vim.api.nvim_buf_get_name(bufnr) ~= vim.b[bufnr].term_title then
        local title = vim.b[bufnr].term_title
        local wrong_title = vim.api.nvim_buf_get_name(bufnr)
        if not vim.startswith(title, "term://") then
          title = string.format("%s (%d)", vim.b[bufnr].term_title, vim.fn.jobpid(vim.bo[bufnr].channel))
        end
        vim.api.nvim_buf_set_name(bufnr, title)
        local wrong_title_bufnr = vim.fn.bufnr(wrong_title)
        vim.api.nvim_buf_delete(wrong_title_bufnr, { force = true })
      end

      vim.keymap.set("n", "<A-h>", [[<C-\><C-N><C-W>h]], { buffer = bufnr })
      vim.keymap.set("n", "<A-j>", [[<C-\><C-N><C-W>j]], { buffer = bufnr })
      vim.keymap.set("n", "<A-k>", [[<C-\><C-N><C-W>k]], { buffer = bufnr })
      vim.keymap.set("n", "<A-l>", [[<C-\><C-N><C-W>l]], { buffer = bufnr })
    end)
  end,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
  pattern = "term://*",
  group = terminal_setup,
  desc = "Line numbers are not helpful in terminal buffers",
  callback = function()
    vim.wo.number = false
  end,
})

vim.api.nvim_create_autocmd("TermEnter", {
  group = terminal_setup,
  callback = function()
    if not require("lbrayner").window_is_floating() then
      local terminals = vim.tbl_filter(function(win)
        local bufnr = vim.api.nvim_win_get_buf(win)
        return vim.bo[bufnr].buftype == "terminal"
      end, vim.api.nvim_tabpage_list_wins(0))
      if vim.tbl_count(terminals) > 1 then
        vim.opt.winhighlight:append({ Normal = "CursorLine" })
      end
    end
  end,
})

vim.api.nvim_create_autocmd("TermLeave", {
  group = terminal_setup,
  callback = function()
    vim.opt.winhighlight:remove({ "Normal" })
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  group = terminal_setup,
  desc = "Start in terminal mode",
  callback = function()
    vim.api.nvim_create_autocmd("TermOpen", {
      group = terminal_setup,
      callback = function(args)
        local bufnr = args.buf
        local file = vim.api.nvim_buf_get_name(bufnr)
        local filename = vim.fn.fnamemodify(file, ":t")
        if vim.startswith(filename, "Neogit") then
          return
        end
        vim.cmd.startinsert()
      end,
    })
  end,
})

if vim.v.vim_did_enter == 1 then
  vim.api.nvim_exec_autocmds("VimEnter", { group = terminal_setup })
end
