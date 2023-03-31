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

return {
  switch_to_window = switch_to_window,
}
