local M = {}

function M.cwd()
  return vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
end

function M.directory()
  return vim.fn.expand("%:p:~:h")
end

---@return string?
function M.first_level()
  local directory = M.directory()

  if not M.is_in_directory(directory, vim.fn.getcwd()) then
    return
  end

  local first_level = vim.fs.root(directory, function(_, path)
    return vim.fn.fnamemodify(path, ":h") == vim.fn.getcwd()
  end)

  return first_level
end

---@return string?
function M.first_level_name()
  local first_level = M.first_level()

  if not first_level then
    return
  end

  return vim.fn.fnamemodify(first_level, ":t")
end

function M.folder_name()
  return vim.fn.expand("%:p:h:t")
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

function M.working_directory_name()
  return vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
end

return M
