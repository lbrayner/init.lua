-- vim: fdm=marker

local endswith = vim.endswith
local fs_stat = vim.uv.fs_stat
local glob = vim.fn.glob
local joinpath = vim.fs.joinpath
local list_extend = vim.list_extend
local normalize = vim.fs.normalize
local stdpath = vim.fn.stdpath
local tbl_deep_extend = vim.tbl_deep_extend
local tbl_filter = vim.tbl_filter
local tbl_isempty = vim.tbl_isempty
local tbl_map = vim.tbl_map
local uri_from_fname = vim.uri_from_fname

local M = {}

function M.get(...)
  local capabilities = tbl_deep_extend("keep", {
    -- effectively enable vim.lsp.buf.declaration()
    textDocument = {
      declaration = {
        dynamicRegistration = true,
      },
    },
  }, vim.lsp.protocol.make_client_capabilities())

  local data = stdpath("data")
  local java_debug_jar_glob_pattern = joinpath(
    data,
    "java-debug",
    "default",
    "com.microsoft.java.debug.plugin",
    "target",
    "com.microsoft.java.debug.plugin-*.jar"
  )
  local vscode_java_test_jar_glob_pattern = joinpath(
    data, "vscode-java-test/default/server/*.jar"
  )

  return tbl_deep_extend("force", {}, {
    capabilities = capabilities,
    cmd = {
      "jdtls",
      "-configuration", normalize("~/.cache/jdtls/default/config"),
      "-data", normalize("~/.cache/jdtls/default/workspace"),
    },
    init_options = {
      bundles = (function()
        local java_debug_jars = glob(java_debug_jar_glob_pattern, 1, 1)

        if #java_debug_jars ~= 1 then
          return
        end

        local bundles = java_debug_jars

        local vscode_java_test_jars = tbl_filter(function(jar)
          -- {{{ github issue
          -- https://github.com/eclipse-jdtls/eclipse.jdt.ls/issues/2761#issuecomment-1638311201.
          -- }}}
          -- Not all jars in vscode-java-test/server should be passed in the
          -- bundles setting.
          return not endswith(
            jar, "com.microsoft.java.test.runner-jar-with-dependencies.jar"
          ) and not endswith(jar, "jacocoagent.jar")
        end, glob(vscode_java_test_jar_glob_pattern, 1, 1))

        list_extend(bundles, vscode_java_test_jars)

        if not tbl_isempty(bundles) then
          return bundles
        end
      end)(),
    },
  }, ...)
end

function M.get_eclipse_preferences(file)
  return {
    settings = {
      java = {
        settings = {
          url = (function()
            file = normalize(file)
            if fs_stat(file) then
              return file
            end
          end)(),
        }
      }
    },
  }
end

function M.get_root_dir()
  return {
    root_dir = require("jdtls.setup").find_root({".git", "mvnw", "gradlew"}),
  }
end

function M.get_workspace_folders(folders)
  if type(folders) == "string" then
    folders = { folders }
  end

  return {
    init_options = {
      workspaceFolders = tbl_map(
        function(w)
          return uri_from_fname(normalize(w))
        end,
        folders
      )
    },
    workspace_folders = tbl_map(
      function(w)
        return {
          name = normalize(w),
          uri = uri_from_fname(normalize(w)),
        }
      end,
      folders
    ),
  }
end

return M
