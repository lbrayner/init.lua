local M = {}

-- Modified test_class from nvim-jdtls/lua/jdtls/dap.lua so that additional
-- vmArgs can be supplied via environment variable

--- @param opts JdtTestOpts|nil
function M.test_class(opts)
  -- nvim-jdtls internal function
  local function get_first_class_lens(lenses)
    for _, lens in pairs(lenses) do
      -- compatibility for versions prior to
      -- https://github.com/microsoft/vscode-java-test/pull/1257
      -- LegacyTestLevel.Class is 3
      if lens.level == 3 then
        return lens
      end
      -- TestLevel.Class is 5
      if lens.testLevel == 5 then
        return lens
      end
    end
  end

  opts = opts or {}
  local context = require("jdtls.dap").experimental.make_context(opts.bufnr)
  require("jdtls.dap").experimental.fetch_lenses(context, function(lenses)
    local lens = get_first_class_lens(lenses)
    if not lens then
      vim.notify("No test class found")
      return
    end
    require("jdtls.dap").experimental.fetch_launch_args(lens, context, function(launch_args)
      -- JdtTestOpts.config_overrides of type JdtDapConfig completely overrides
      -- arguments, such as vmArgs. See function `make_config` in
      -- nvim-jdtls/lua/jdtls/dap.lua, which is invoked in the following
      -- statement.
      local config = require("jdtls.dap").experimental.make_config(lens, launch_args, opts.config_overrides)
      -- Get extra JVM args from environment
      local dap_jvm_args = os.getenv("DAP_JVM_ARGS")

      if dap_jvm_args and dap_jvm_args ~= "" then
        config.vmArgs = config.vmArgs .. " " .. dap_jvm_args
      end

      require("jdtls.dap").experimental.run(lens, config, context, opts)
    end)
  end)
end

return M
