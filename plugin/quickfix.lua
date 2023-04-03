local function switch_to_window()
  local linenr = vim.api.nvim_win_get_cursor(0)[1]
  local bufnr = vim.fn.getqflist()[linenr].bufnr
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(w)
    if buf == bufnr then
      vim.api.nvim_set_current_win(w)
    end
  end
  vim.cmd(linenr .. "cc")
end

local qf_setup = vim.api.nvim_create_augroup("QuickfixBufferSetup", { clear=true })

vim.api.nvim_create_autocmd("FileType", {
  group = qf_setup,
  desc = "Quickfix buffer setup",
  pattern = "qf",
  callback = function(args)
    local bufnr = args.buf
    local wininfos = vim.tbl_filter(function(wininfo)
      return wininfo.bufnr == bufnr
    end, vim.fn.getwininfo())

    for _, wininfo in ipairs(wininfos) do
      local winid = wininfo.winid

      vim.wo[winid].spell = false
      vim.wo[winid].wrap = false

      -- Exclusive to quickfix
      if vim.fn.getwininfo(winid)[1].loclist < 1 then
        vim.keymap.set("n", "<CR>", switch_to_window, { buffer=bufnr })
      end
    end
  end,
})