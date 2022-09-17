vim.api.nvim_create_user_command("LuaModuleReload", function(command)
    local module, replacements
    module = string.gsub(command.args, "^lua/", "")
    module, replacements = string.gsub(module, "/", ".")
    if replacements > 0 then
        module = string.gsub(module, "%.lua$", "")
    end
    package.loaded[module] = nil
    require(module)
    print(string.format("Reloaded '%s'.", module))
end, { bar=true, nargs=1 })
