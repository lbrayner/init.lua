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
  if vim.startswith(vim.uri_from_bufnr(bufnr), "fugitive://") then
    local fugitive_path = require("lbrayner.fugitive").get_fugitive_path()
    fugitive_path = vim.fs.normalize(vim.fn.fnamemodify(fugitive_path, ":p"))
    return vim.fn.fnamemodify(fugitive_path, ":~")
  end
  if not vim.startswith(vim.uri_from_bufnr(bufnr), "file://") then
    return bufname
  end
  return vim.fn.fnamemodify(bufname, ":~")
end

function M.is_in_directory(node, directory, opts)
  node = vim.fs.normalize(vim.fn.fnamemodify(node, ":p"))
  directory = vim.fs.normalize(vim.fn.fnamemodify(directory, ":p"))
  opts = opts or {}
  if opts.exclusive and node == directory  then
    return false
  end
  return vim.startswith(node, directory)
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
  if vim.startswith(vim.uri_from_bufnr(bufnr), "fugitive://") then
    return require("lbrayner.fugitive").get_fugitive_path()
  end
  if not vim.startswith(vim.uri_from_bufnr(bufnr), "file://") then
    return bufname
  end
  if not M.is_in_directory(bufname, vim.fn.getcwd(), { exclusive = true }) then
    return M.full_path() -- In case buffer represents a directory
  end
  return vim.fn.fnamemodify(bufname, ":.")
end

function M.relative_directory()
  return vim.fn.expand("%:h")
end

return M
