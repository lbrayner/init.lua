local M = {}

local fnamemodify = vim.fn.fnamemodify

function M.cwd()
  return fnamemodify(vim.fn.getcwd(), ":~")
end

function M.directory()
  return fnamemodify(M.path(), ":p:~:h")
end

---@return string?
function M.first_level()
  local directory = M.directory()

  if not M.is_in_directory(directory, vim.fn.getcwd()) then
    return
  end

  local first_level = vim.fs.root(directory, function(_, path)
    return fnamemodify(path, ":h") == vim.fn.getcwd()
  end)

  if first_level then
    return fnamemodify(first_level, ":~")
  end
end

---@return string?
function M.first_level_name()
  local first_level = M.first_level()

  if not first_level then
    return
  end

  return fnamemodify(first_level, ":t")
end

function M.folder_name()
  return fnamemodify(M.path(), "%:p:h:t")
end

function M.full_path(path)
  assert(not path or type(path) == "string", "'path' must be a string")

  if not path then
    local bufnr = 0
    local bufname = vim.api.nvim_buf_get_name(bufnr)

    if bufname == "" then
      return ""
    end

    if not vim.startswith(vim.uri_from_bufnr(bufnr), "file://") then
      return bufname
    end

    path = M.path()
  end

  return fnamemodify(path, ":p:~")
end

function M.is_in_directory(node, directory, opts)
  node = vim.fs.normalize(fnamemodify(node, ":p"))
  directory = vim.fs.normalize(fnamemodify(directory, ":p"))
  opts = opts or {}

  if opts.exclusive and node == directory  then
    return false
  end

  return vim.startswith(node, directory)
end

function M.name()
  return fnamemodify(M.path(), ":t")
end

function M.path()
  local bufnr = 0
  local bufname = vim.api.nvim_buf_get_name(bufnr)

  if bufname == "" then
    return ""
  end

  if vim.startswith(vim.uri_from_bufnr(bufnr), "jdt://") then
    return require("lbrayner.jdtls").get_buffer_name(bufnr)
  end

  if vim.startswith(vim.uri_from_bufnr(bufnr), "fugitive://") then
    return require("lbrayner.fugitive").get_fugitive_path()
  end

  if not vim.startswith(vim.uri_from_bufnr(bufnr), "file://") then
    return bufname
  end

  if not M.is_in_directory(bufname, vim.fn.getcwd(), { exclusive = true }) then
    return M.full_path(bufname) -- In case buffer represents a directory
  end

  return fnamemodify(bufname, ":.")
end

function M.relative_directory()
  return fnamemodify(M.path(), ":h")
end

function M.working_directory_name()
  return fnamemodify(vim.fn.getcwd(), ":p:h:t")
end

return M
