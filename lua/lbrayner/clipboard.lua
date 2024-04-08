local M = {}

function M.clip(text)
  if text then
    text = tostring(text)
    vim.fn.setreg('"', text)
  end
  vim.fn.setreg("+", vim.fn.getreg('"'))
  vim.fn.setreg("*", vim.fn.getreg('"'))
  vim.notify(vim.fn.getreg('"'))
end

vim.api.nvim_create_user_command("Clip", function(command)
  M.clip(command.args)
end, { nargs = "?" })
vim.api.nvim_create_user_command("Cwd", function()
  M.clip(require("lbrayner.path").cwd())
end, { nargs = 0 })
vim.api.nvim_create_user_command("Directory", function()
  M.clip(require("lbrayner.path").directory())
end, { nargs = 0 })
vim.api.nvim_create_user_command("FullPath", function()
  local fugitive_path = require("lbrayner.fugitive").fugitive_path()
  if fugitive_path then
    M.clip(vim.fn.fnamemodify(fugitive_path, ":p:~"))
    return
  end
  M.clip(require("lbrayner.path").full_path())
end, { nargs = 0 })
vim.api.nvim_create_user_command("Name", function()
  M.clip(require("lbrayner.path").name())
end, { nargs = 0 })
vim.api.nvim_create_user_command("Path", function()
  local fugitive_path = require("lbrayner.fugitive").fugitive_path()
  if fugitive_path then
    M.clip(fugitive_path)
    return
  end
  M.clip(require("lbrayner.path").path())
end, { nargs = 0 })
vim.api.nvim_create_user_command("RelativeDirectory", function()
  M.clip(require("lbrayner.path").relative_directory())
end, { nargs = 0 })

return M
