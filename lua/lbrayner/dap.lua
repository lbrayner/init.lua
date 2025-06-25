local M = {}

---@class dap.run.opts
---@field new? boolean force new session
---@field before? fun(config: dap.Configuration): dap.Configuration pre-process config
function M.continue(opts)
  opts = opts or {}

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

return M
