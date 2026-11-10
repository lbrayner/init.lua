local notify = vim.notify

local M = {}

function M.attach(config)
  config = config or {}
  config.request = "attach"
  config.type = "java"

  local dap = require("dap")
  local name = config.name

  _G.dap_original_java_adapter = _G.dap_original_java_adapter or dap.adapters.java

  dap.adapters.java = function(callback, config)
    dap.adapters.java = _G.dap_original_java_adapter

    if config.request == "attach" then
      config.name = config.name or name
      config.mainClass = config.mainClass or "__attach__"
      config.modulePaths = config.modulePaths or {}
      config.classPaths = config.classPaths or {}
      config.javaExec = config.javaExec or "__attach__"

      if not config.projectName then
        config.projectName = require("lbrayner.jdtls").get_current_project_name()
      end

      if not config.projectName then
        notify(
          "Java DAP Attach must be run from within a JDTLS project.",
          vim.log.levels.WARN
        )
        return
      end
    end

    _G.dap_original_java_adapter(callback, config)
  end

  dap.run(config)
end

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
        M.redefine_classes()
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

function M.debug_support_on_decompiled_source()
  require("jdtls.util").execute_command(
    {
      command = "vscode.java.updateDebugSettings",
      arguments = {
        vim.json.encode({
          debugSupportOnDecompiledSource = "on",
          logLevel = "INFO",
        }),
      },
    },
    function(err, result)
      assert(not err, vim.inspect(err))
      print(vim.inspect(vim.json.decode(result)))
    end
  )
end

-- From jdtls/setup.lua JdtUpdateHotcode
function M.redefine_classes()
  local session = require("dap").session()

  if not session then
    notify("No active debug session")
    return
  end

  notify("Applying code changes")
  session:request("redefineClasses", nil, function(err)
    assert(not err, inspect(err))
  end)
end

---@class JdtTestOpts
---...
---@field on_config nil|function Callback called after config is assembled

local function setup_on_config(opts)
  opts = opts or {}
  local on_config = opts.on_config

  if not on_config then return end

  local dap = require("dap")

  _G.dap_original_java_adapter = _G.dap_original_java_adapter or dap.adapters.java

  dap.adapters.java = function(callback, config)
    dap.adapters.java = _G.dap_original_java_adapter
    on_config(config)
    _G.dap_original_java_adapter(callback, config)
  end
end

--- Debug the test class in the current buffer
--- @param opts JdtTestOpts|nil
function M.test_class(opts)
  setup_on_config(opts)
  require("jdtls").test_class(opts)
end

--- Debug the nearest test method in the current buffer
--- @param opts nil|JdtTestOpts
function M.test_nearest_method(opts)
  setup_on_config(opts)
  require("jdtls").test_nearest_method(opts)
end

return M
