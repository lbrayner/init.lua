-- TODO move to init.lua
require("tint").setup({
  highlight_ignore_patterns = { "^VertSplit", "^WinSeparator", },
  window_ignore_function = function(winid)
    -- TODO modernize this
    local bufid = vim.api.nvim_win_get_buf(winid)
    local buftype = vim.api.nvim_buf_get_option(bufid, "buftype")
    local floating = vim.api.nvim_win_get_config(winid).relative ~= ""

    -- Do not tint  floating windows, or windows with special buffers, tint everything else
    return buftype ~= "" or floating
  end
})
