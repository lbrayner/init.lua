vim.api.nvim_create_user_command("LuaModuleReload", function(command)
    local module = command.args
    package.loaded[module] = nil
    require(module)
end, { bar=true, nargs=1 })
