local M = {}

function M.diff_include_expression(fname)
  -- diff hunks in vim-fugitive buffers
  local fname = string.gsub(fname, "^[ab]/", "")
  return fname
end

function M.fugitive_path()
  if vim.fn.exists("*FugitiveReal") == 1 then
    local fugitive_path = vim.fn.fnamemodify(vim.fn.FugitiveReal(vim.api.nvim_buf_get_name(0)), ":~:.")
    if fugitive_path ~= "" then
      return fugitive_path
    end
  end
end

function M.fugitive_object()
  if vim.fn.exists("*FugitiveParse") == 1 then
    local fugitive_object = vim.fn.FugitiveParse(vim.api.nvim_buf_get_name(0))[1]
    if fugitive_object ~= "" then
      return fugitive_object
    end
  end
end

return M
