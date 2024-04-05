local M = {}

function M.diff_include_expression(fname)
  -- diff hunks in vim-fugitive buffers
  local fname = string.gsub(fname, "^[ab]/", "")
  return fname
end

function M.fugitive_git_dir()
  if vim.fn.exists("*FugitiveGitDir") == 1 and vim.fn.FugitiveGitDir() ~= "" then
    local dir, _ = string.gsub(vim.fn.fnamemodify(vim.fn.FugitiveGitDir(), ":~"), "/%.git$", "")
    return dir
  end
end

function M.fugitive_object()
  if vim.fn.exists("*FugitiveParse") == 1 then
    local object = vim.fn.FugitiveParse(vim.api.nvim_buf_get_name(0))[1]
    if object ~= "" then
      return object
    end
  end
end

function M.fugitive_path()
  if vim.fn.exists("*FugitiveReal") == 1 then
    local path = vim.fn.fnamemodify(vim.fn.FugitiveReal(vim.api.nvim_buf_get_name(0)), ":~:.")
    if path ~= "" then
      return path
    end
  end
end

return M
