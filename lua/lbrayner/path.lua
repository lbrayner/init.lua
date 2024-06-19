local M = {}

function M.cwd()
  return vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
end

function M.directory()
  return vim.fn.expand("%:p:~:h")
end

function M.full_path()
  local bufnr = 0
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  if bufname == "" then
    return ""
  end
  if not vim.startswith(vim.uri_from_bufnr(bufnr), "file://") then
    return bufname
  end
  -- Normalized (remove trailing /) in case buffer represents a directory
  local fp = vim.fs.normalize(vim.fn.expand("%:p"))
  return vim.fn.fnamemodify(fp, ":~")
end

function M.name()
  return vim.fn.expand("%:t")
end

function M.path()
  local bufnr = 0
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  if bufname == "" then
    return ""
  end
  if not vim.startswith(vim.uri_from_bufnr(bufnr), "file://") then
    return bufname
  end
  if not require("lbrayner").is_in_directory(bufname, vim.fn.getcwd(), true) then
    return M.full_path() -- In case buffer represents a directory
  end
  return vim.fn.expand("%:.")
end

function M.relative_directory()
  return vim.fn.expand("%:h")
end

return M
