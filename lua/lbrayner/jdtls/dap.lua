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

local function attach(config)
  local dap = require("dap")
  local name = config.name

  _G.original_java_adapter = _G.original_java_adapter or dap.adapters.java

  dap.adapters.java = function(callback, config)
    dap.adapters.java = _G.original_java_adapter

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
        vim.notify(
          "Java DAP Attach must be run from within a JDTLS project.",
          vim.log.levels.WARN
        )
        return
      end
      config.name = config.name or "Attach to WebSphere 9"
    end

    _G.original_java_adapter(callback, config)
  end

  dap.run(config)
end

-- Start a JDWP Maven Surefire/Failsafe Cucumber test JVM
-- mvn test \
--   -Dtest=UnitarioTest \
--   -Dcucumber.features=classpath:feature/foo.feature:42 \
--   -Dcucumber.plugin=pretty \
--   -Dmaven.surefire.debug
-- mvn test -am -pl api-module \
--   -Dtest=UnitarioTest \
--   -Dcucumber.features=classpath:feature/foo.feature:42 \
--   -Dcucumber.plugin=pretty \
--   -Dsurefire.failIfNoSpecifiedTests=false \
--   -Dmaven.surefire.debug
-- mvn verify \
--   -Dit.test=BatchIT \
--   -Dcucumber.features=classpath:feature/bar.feature:19 \
--   -Dcucumber.plugin=pretty \
--   -Dmaven.failsafe.debug
function M.maven_attach()
  attach({
    type = "java",
    name = "Attach to Maven Surefire/Failsafe",
    request = "attach",
    hostName = "localhost",
    port = 5005,
  })
end

function M.websphere9_attach()
  attach({
    type = "java",
    name = "Attach to WebSphere 9",
    request = "attach",
    hostName = "localhost",
    port = 7777,
  })
end

---@class JdtTestOpts
---...
---@field on_config nil|function Callback called after config is assembled

local function setup_on_config(opts)
  opts = opts or {}
  local on_config = opts.on_config

  if not on_config then return end

  local dap = require("dap")
  _G.original_java_adapter = _G.original_java_adapter or dap.adapters.java

  dap.adapters.java = function(callback, config)
    dap.adapters.java = _G.original_java_adapter
    on_config(config)
    _G.original_java_adapter(callback, config)
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
