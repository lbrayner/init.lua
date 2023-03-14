vim.cmd.packadd "nvim-jdtls"

local lspconfig = require "lspconfig.server_configurations.jdtls"

return {
  get_config = function()
    return {
      cmd = lspconfig.default_config.cmd,
      root_dir = require("jdtls.setup").find_root({".git", "mvnw", "gradlew"}),
      url = (function()
        local prefs = os.getenv("HOME").."/.config/nvim/config/jdtls/settings.prefs"
        if vim.fn.filereadable(prefs) == 1 then
          return prefs
        end
      end)(),
    }
  end,
}
