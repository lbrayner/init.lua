local lspconfig = require "lspconfig.server_configurations.jdtls"

return {
  get_config = function()
    return {
      cmd = lspconfig.default_config.cmd,
      root_dir = require("jdtls.setup").find_root({".git", "mvnw", "gradlew"}),
      url = (function()
        local prefs = vim.fn.fnamemodify("~/.config/nvim/config/jdtls/settings.prefs", ":p")
        if vim.fn.filereadable(prefs) == 1 then
          return prefs
        end
      end)(),
    }
  end,
}
