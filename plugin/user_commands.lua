local function module_reload(command)
    local module = command.args
    package.loaded[module] = nil
    require(module)
end

vim.api.nvim_create_user_command("LuaModuleReload", module_reload, { bar=true, nargs = 1 })
