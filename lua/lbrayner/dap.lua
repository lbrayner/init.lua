local function continue(opts)
  require("dap").continue(vim.tbl_extend("force", {
    before = function(config)
      local success, session = pcall(require, "lbrayner.session")

      if success and session.dap_run_before and type(session.dap_run_before) == "function" then
        config = session.dap_run_before(config)
      end

      return config
    end
  }, opts))
end

local M = {}

---@class dap.run.opts
---@field new? boolean force new session
---@field before? fun(config: dap.Configuration): dap.Configuration pre-process config
function M.continue(opts)
  opts = opts or {}

  if session and session.stopped_thread_id then
    require("dap").continue(opts)
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()

  -- from dap.nvim's select_config_and_run(opts)
  local providers = require("dap").providers
  local all_configs = {}
  local provider_keys = vim.tbl_keys(providers.configs)
  table.sort(provider_keys)
  for _, provider in ipairs(provider_keys) do
    local config_provider = providers.configs[provider]
    local configs = config_provider(bufnr)
    if vim.islist(configs) then
      vim.list_extend(all_configs, configs)
    end
  end

  if #all_configs == 1 then
    vim.ui.select(
      {
        { command = "dap_continue", description = "DAP continue..." },
        { command = "do_nothing", description = "Do nothing" },
      },
      {
        prompt = "There is only one DAP configuration. What would you like to do?",
        format_item = function(c) return c.description end,
      },
      function(c)
        if not c then return end

        if c.command == "dap_continue" then
          continue(opts)
        end
      end
    )
  else
    continue(opts)
  end
end

return M
