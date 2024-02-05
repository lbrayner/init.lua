local M = {}

function M.diff_include_expression(fname)
  -- diff hunks in vim-fugitive buffers
  local fname = string.gsub(fname, "^[ab]/", "")
  return fname
end

function M.fugitive_full_path()
  return vim.fn.fnamemodify(vim.fn.FugitiveReal(vim.api.nvim_buf_get_name(0)), ":~:.")
end

function M.fugitive_object()
  return vim.fn.FugitiveParse(vim.api.nvim_buf_get_name(0))[1]
end

return M
