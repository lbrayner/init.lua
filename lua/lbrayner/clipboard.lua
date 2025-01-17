local M = {}

function M.clip(text)
  if text then
    text = tostring(text)
    vim.fn.setreg('"', text)
  end
  vim.fn.setreg("+", vim.fn.getreg('"'))
  vim.notify(vim.fn.getreg("+"))
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
vim.api.nvim_create_user_command("FolderName", function()
  M.clip(require("lbrayner.path").folder_name())
end, { nargs = 0 })
vim.api.nvim_create_user_command("FullPath", function()
  M.clip(require("lbrayner.path").full_path())
end, { nargs = 0 })
vim.api.nvim_create_user_command("Name", function()
  M.clip(require("lbrayner.path").name())
end, { nargs = 0 })
vim.api.nvim_create_user_command("Path", function()
  M.clip(require("lbrayner.path").path())
end, { nargs = 0 })
vim.api.nvim_create_user_command("RelativeDirectory", function()
  M.clip(require("lbrayner.path").relative_directory())
end, { nargs = 0 })
vim.api.nvim_create_user_command("WorkingDirectoryName", function()
  M.clip(require("lbrayner.path").working_directory_name())
end, { nargs = 0 })

return M
