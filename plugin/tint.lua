-- TODO move to init.lua
require("tint").setup({
  highlight_ignore_patterns = { "^VertSplit", "^WinSeparator", },
  window_ignore_function = function(winid)
    local diff = vim.wo[winid].diff
    local preview = vim.wo[winid].previewwindow
    local bufnr = vim.api.nvim_win_get_buf(winid)
    local buftype = vim.bo[bufnr].buftype
    local floating = vim.api.nvim_win_get_config(winid).relative ~= ""

    return diff or preview or buftype ~= "" or floating
  end
})
