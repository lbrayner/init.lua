-- TODO move to init.lua
local success = pcall(require, "dapui")

if not success then
  return
end

require("dapui").setup()

vim.api.nvim_create_user_command("DapUiClose", function(command)
  require("dapui").close({ layout = tonumber(command.args) })
end, { nargs = "?" })

vim.api.nvim_create_user_command("DapUiOpen", function(command)
  require("dapui").open({ layout = tonumber(command.args) })
end, { nargs = "?" })

vim.api.nvim_create_user_command("DapUiReset", require("dapui").setup, { nargs = 0 })
