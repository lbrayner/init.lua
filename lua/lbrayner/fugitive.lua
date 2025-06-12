local M = {}

function M.include_expression(fname)
  -- diff hunks in vim-fugitive buffers
  local fname = string.gsub(fname, "^[ab]/", "")
  return fname
end

function M.get_fugitive_git_dir()
  if vim.fn.exists("*FugitiveGitDir") == 1 and vim.fn.FugitiveGitDir() ~= "" then
    local dir, _ = string.gsub(vim.fn.FugitiveGitDir(), "/%.git$", "")
    return dir
  end
end

function M.get_fugitive_object()
  if vim.fn.exists("*FugitiveParse") == 1 then
    local object = vim.fn.FugitiveParse(vim.api.nvim_buf_get_name(0))[1]
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

function M.is_fugitive_blame(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if vim.fn.exists("*FugitiveResult") == 1 then
    local fugitive_result = vim.fn.FugitiveResult(bufnr)
    if fugitive_result.filetype and
      fugitive_result.blame_file and
      fugitive_result.filetype == "fugitiveblame" then
      return true
    end
  end
end

function M.setup()
  require("lbrayner.fugitive._setup")
end

return M
