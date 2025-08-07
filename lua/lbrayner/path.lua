local M = {}

local fnamemodify = vim.fn.fnamemodify

function M.get_cwd()
  return fnamemodify(vim.fn.getcwd(), ":~")
end

function M.get_directory()
  return fnamemodify(M.get_path(), ":p:~:h")
end

---@return string?
function M.get_first_level()
  local directory = M.get_directory()

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
function M.get_first_level_name()
  local first_level = M.get_first_level()

  if not first_level then
    return
  end

  return fnamemodify(first_level, ":t")
end

function M.get_folder_name()
  return fnamemodify(M.get_path(), ":p:h:t")
end

function M.get_full_path(path)
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

    path = M.get_path()
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

function M.get_name()
  return fnamemodify(M.get_path(), ":t")
end

function M.get_path()
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
    return M.get_full_path(bufname) -- In case buffer represents a directory
  end

  return fnamemodify(bufname, ":.")
end

function M.get_relative_directory()
  return fnamemodify(M.get_path(), ":h")
end

function M.get_working_directory_name()
  return fnamemodify(vim.fn.getcwd(), ":p:h:t")
end

-- Insert path (use i_CTRL-R)
vim.cmd([[
function! Cwd()
  return v:lua.require'lbrayner.path'.cwd()
endfunction

function! Directory()
  return v:lua.require'lbrayner.path'.directory()
endfunction

function! FirstLevel()
  return v:lua.require'lbrayner.path'.first_level()
endfunction

function! FirstLevelName()
  return v:lua.require'lbrayner.path'.first_level_name()
endfunction

function! FolderName()
  return v:lua.require'lbrayner.path'.folder_name()
endfunction

function! FullPath()
  return v:lua.require'lbrayner.path'.full_path()
endfunction

function! Name()
  return v:lua.require'lbrayner.path'.name()
endfunction

function! Path()
  return v:lua.require'lbrayner.path'.path()
endfunction

function! RelativeDirectory()
  return v:lua.require'lbrayner.path'.relative_directory()
endfunction

function! WorkingDirectoryName()
  return v:lua.require'lbrayner.path'.working_directory_name()
endfunction
]])

return M
