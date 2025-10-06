local M = {}

local join = require("lbrayner").join

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

function M.terminal_win_cmd(config)
  local success, dapui = pcall(require, "dapui")

  if not success then
    vim.api.nvim_command("belowright new")
    local bufnr = vim.api.nvim_get_current_buf()
    local win = vim.api.nvim_get_current_win()
    vim.api.nvim_set_current_win(cur_win)
    return bufnr, win
  end

  local settings = require("dap").defaults[config.type]
  local bufnr = dapui.elements.console.buffer()

  if not vim.b[bufnr].terminal_job_pid then
    return bufnr
  end

  if not vim.api.nvim_get_proc(vim.b[bufnr].terminal_job_pid) then
    return bufnr
  end

  bufnr = require("dapui.util").create_buffer(
    join({ "DAP Console", bufnr }), { filetype = "dapui_console" }
  )()

  return bufnr
end

require("dap").defaults.fallback.terminal_win_cmd = function(config)
  return require("lbrayner.jdtls.dap").terminal_win_cmd(config)
end

return M
