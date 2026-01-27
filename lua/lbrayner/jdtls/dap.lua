local M = {}

function M.continue()
  local session = require("dap").session()

  if not session or
    session and session.stopped_thread_id or
    session and vim.tbl_get(session, "config", "type") ~= "java" or
    session and not vim.tbl_get(session, "config", "mainClass") then
    require("lbrayner.dap").continue()
    return
  end

  vim.ui.select(
    {
      { command = "redefine_classes", description = "Hot code replace (redefineClasses)" },
      { command = "dap_new", description = "Start additional session" },
      { command = "dap_terminate", description = "Terminate session" },
      { command = "dap_terminate_all", description = "Terminate all sessions" },
      { command = "dap_continue", description = "See more DAP options..." },
    },
    {
      prompt = string.format("Java Debug Server session “%s” active> ", session.config.name),
      format_item = function(c) return c.description end,
    },
    function(c)
      if not c then return end

      if c.command == "redefine_classes" then
        require("lbrayner.jdtls").java_redefine_classes()
      elseif c.command == "dap_new" then
        ---@class dap.run.opts
        ---@field new? boolean force new session
        ---@field before? fun(config: dap.Configuration): dap.Configuration pre-process config
        require("lbrayner.dap").continue({ new = true })
      elseif c.command == "dap_terminate" then
        require("dap").terminate()
      elseif c.command == "dap_terminate_all" then
        require("dap").terminate({ all = true })
      else
        require("lbrayner.dap").continue()
      end
    end
  )
end

return M
