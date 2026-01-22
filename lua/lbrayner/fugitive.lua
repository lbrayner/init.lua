local M = {}

function M.include_expression(fname)
  -- diff hunks in vim-fugitive buffers
  local fname = string.gsub(fname, "^[ab]/", "")
  return fname
end

function M.get_fugitive_object(bufnr)
  bufnr = bufnr or 0

  if vim.fn.exists("*FugitiveParse") == 1 then
    local object = vim.fn.FugitiveParse(vim.api.nvim_buf_get_name(bufnr))[1]
    if object ~= "" then
      return object
    end
  end
end

function M.get_fugitive_path()
  if vim.fn.exists("*FugitiveReal") == 1 then
    local path = vim.fn.fnamemodify(vim.fn.FugitiveReal(vim.api.nvim_buf_get_name(0)), ":~:.")
    if path ~= "" then
      return path
    end
  end
end

function M.setup()
  require("lbrayner.fugitive._setup")
end

return M
