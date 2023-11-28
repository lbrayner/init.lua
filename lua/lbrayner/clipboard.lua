local M = {}

function M.path()
  if vim.api.nvim_buf_get_name(0) == "" then
    return ""
  end
  if not require("lbrayner").is_in_directory(vim.api.nvim_buf_get_name(0), vim.fn.getcwd(), true) then
    return M.full_path() -- In case buffer represents a directory
  end
  return vim.fn.expand("%:.")
end

function M.full_path()
  return vim.fn.expand("%:~")
end

function M.name()
  return vim.fn.expand("%:t")
end

function M.cwd()
  return vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
end

function M.directory()
  return vim.fn.expand("%:~:h")
end

function M.relative_directory()
  return vim.fn.expand("%:h")
end

function M.clip(text)
  if text then
    text = tostring(text)
    vim.fn.setreg('"', text)
  end
  vim.fn.setreg("+", vim.fn.getreg('"'))
  vim.fn.setreg("*", vim.fn.getreg('"'))
  vim.cmd.echo(string.format("'%s'", vim.fn.getreg('"')))
end

vim.api.nvim_create_user_command("Clip", function(command)
  M.clip(command.args)
end, { nargs = "?" })

vim.api.nvim_create_user_command("Path", function()
  M.clip(M.path())
end, { nargs = 0 })
vim.api.nvim_create_user_command("FullPath", function()
  M.clip(M.full_path())
end, { nargs = 0 })
vim.api.nvim_create_user_command("Name", function()
  M.clip(M.name())
end, { nargs = 0 })
vim.api.nvim_create_user_command("Cwd", function()
  M.clip(M.cwd())
end, { nargs = 0 })
vim.api.nvim_create_user_command("Directory", function()
  M.clip(M.directory())
end, { nargs = 0 })
vim.api.nvim_create_user_command("RelativeDirectory", function()
  M.clip(M.relative_directory())
end, { nargs = 0 })

return M
