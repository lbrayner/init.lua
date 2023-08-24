-- TODO move to init.lua
require("dapui").setup()

vim.api.nvim_create_user_command("DapUiClose", function(command)
  require("dapui").close({ layout = tonumber(command.args) })
end, { nargs = "?" })

vim.api.nvim_create_user_command("DapUiOpen", function(command)
  require("dapui").open({ layout = tonumber(command.args) })
end, { nargs = "?" })

vim.api.nvim_create_user_command("DapUiReset", function(command)
  require("dapui").setup()
end, { nargs = 0 })
