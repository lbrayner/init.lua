local M = {}

---@class dap.run.opts
---@field new? boolean force new session
---@field before? fun(config: dap.Configuration): dap.Configuration pre-process config
function M.continue(opts)
  local session = require("dap").session()

  if not session or session and session.stopped_thread_id then
    require("lbrayner.dap").continue(opts)
    return
  end

  vim.ui.select(
    {
      { command = "redefine_classes", description = "Hot code replace (redefineClasses)" },
      { command = "dap_continue", description = "See more DAP options..." },
    },
    {
      prompt = "A DAP session is active. What would you like to do?",
      format_item = function(c) return c.description end,
    },
    function(c)
      if not c then return end

      if c.command == "redefine_classes" then
        require("lbrayner.jdtls").java_redefine_classes()
      else
        require("lbrayner.dap").continue(opts)
      end
    end
  )
end

return M
