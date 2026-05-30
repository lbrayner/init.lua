local endswith = vim.endswith
local glob = vim.fn.glob
local list_extend = vim.list_extend
local normalize = vim.fs.normalize
local tbl_deep_extend = vim.tbl_deep_extend
local uri_from_fname = vim.uri_from_fname

local M = {}

function M.get(...)
  local capabilities = tbl_deep_extend("keep", {
    textDocument = {
      declaration = {
        dynamicRegistration = true,
      },
    },
  }, vim.lsp.protocol.make_client_capabilities())

  local java_debug_jar_pattern = vim.fs.joinpath(vim.fn.stdpath("data"),
    "java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar")
  local vscode_java_test_jar_pattern = vim.fs.joinpath(vim.fn.stdpath("data"), "vscode-java-test/server/*.jar")

  return tbl_deep_extend("force", {
    capabilities = capabilities,
    cmd = {
      "jdtls",
      "-configuration", normalize("~/.cache/jdtls/default/config"),
      "-data", normalize("~/.cache/jdtls/default/workspace"),
    },
    init_options = {
      bundles = (function()
        local bundles = {}

        local java_debug_jars = glob(java_debug_jar_pattern, 1, 1)
        if #java_debug_jars == 1 then
          list_extend(bundles, java_debug_jars)
        end

        local vscode_java_test_jars = vim.tbl_filter(function(jar)
          -- https://github.com/eclipse-jdtls/eclipse.jdt.ls/issues/2761#issuecomment-1638311201.
          -- Not all jars in vscode-java-test/server should be passed in the bundles setting.
          return not endswith(jar, "com.microsoft.java.test.runner-jar-with-dependencies.jar") and
          not endswith(jar, "jacocoagent.jar")
        end, glob(vscode_java_test_jar_pattern, 1, 1))

        list_extend(bundles, vscode_java_test_jars)

        if not vim.tbl_isempty(bundles) then
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
            if vim.uv.fs_stat(file) then
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

function M.get_workspace_folders(...)
  local folders = { ... }

  return {
    init_options = {
      workspaceFolders = vim.tbl_map(
        function(w)
          return uri_from_fname(normalize(w))
        end,
        folders
      )
    },
    workspace_folders = vim.tbl_map(
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
