local M = {}

function M.cwd()
  return vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
end

function M.directory()
  return vim.fn.expand("%:p:~:h")
end

function M.full_path()
  -- Normalized (remove trailing /) in case buffer represents a directory
  local fp = vim.fs.normalize(vim.fn.expand("%:p"))
  return vim.fn.fnamemodify(fp, ":~")
end

function M.name()
  return vim.fn.expand("%:t")
end

function M.path()
  if vim.api.nvim_buf_get_name(0) == "" then
    return ""
  end
  if not require("lbrayner").is_in_directory(vim.api.nvim_buf_get_name(0), vim.fn.getcwd(), true) then
    return M.full_path() -- In case buffer represents a directory
  end
  return vim.fn.expand("%:.")
end

function M.relative_directory()
  return vim.fn.expand("%:h")
end

return M
