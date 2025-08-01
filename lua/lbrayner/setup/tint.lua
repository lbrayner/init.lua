local function window_ignore_function(winid)
  local diff = vim.wo[winid].diff
  local preview = vim.wo[winid].previewwindow

  if diff or preview then
    return true
  end

  local floating = vim.api.nvim_win_get_config(winid).relative ~= ""

  if floating then
    return true
  end

  local bufnr = vim.api.nvim_win_get_buf(winid)

  if vim.startswith(vim.api.nvim_buf_get_name(bufnr), "jdt://") then -- jdtls
    return false
  end

  local buftype = vim.bo[bufnr].buftype

  return buftype ~= ""
end

require("tint").setup({
  highlight_ignore_patterns = { "^VertSplit", "^WinSeparator", },
  window_ignore_function = window_ignore_function,
})

local tint_custom = vim.api.nvim_create_augroup("tint_custom", { clear = true })

vim.api.nvim_create_autocmd("VimEnter", {
  group = tint_custom,
  callback = function()
    vim.api.nvim_create_autocmd("WinEnter", {
      group = tint_custom,
      desc = "Dynamically untint ignored windows",
      callback = function()
        local winid = vim.api.nvim_get_current_win()
        if window_ignore_function(winid) then
          require("tint").untint(winid) -- This function checks whether window is already untinted.
        end
      end,
    })
  end,
})

if vim.v.vim_did_enter == 1 then
  vim.api.nvim_exec_autocmds("VimEnter", { group = tint_custom })
end

vim.api.nvim_create_user_command("TintUnTab", function()
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    require("tint").untint(w)
  end
end, { desc = "Untint all windows in a tab", nargs = 0 })
