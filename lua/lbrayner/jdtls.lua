-- vim: fdm=marker

local tbl_contains = vim.tbl_contains
local tbl_get = vim.tbl_get

local M = {}

function M.create_user_command()
  require("lbrayner.jdtls._command")
end

function M.get_buffer_name(bufnr)
  bufnr = bufnr or 0
  local bufname = vim.api.nvim_buf_get_name(bufnr)

  if vim.startswith(bufname, "jdt://") then
    return string.gsub(bufname, "%?.*", "")
  end
end

-- {{{ @class JdtSetupDapOpts
---@class JdtSetupDapOpts
---@field config_overrides JdtDapConfig These will be used as default overrides for |jdtls.dap.test_class|, |jdtls.dap.test_nearest_method| and discovered main classes
---@field hotcodereplace? string "auto"
-- }}}

---@class jdtls.start.opts
---@field dap? JdtSetupDapOpts

---@param config table<string, any> configuration. See |vim.lsp.start_client|
---@param opts? jdtls.start.opts
function M.setup(config, opts)
  opts = opts or {}

  local function start_or_attach()
    require("jdtls").start_or_attach(config)
  end

  local jdtls_setup = vim.api.nvim_create_augroup("jdtls_setup", { clear = true })

  vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    group = jdtls_setup,
    pattern = "*.java",
    desc = "New Java buffers attach to JDT Language Server",
    callback = function(args)
      local bufnr = args.buf

      if not vim.startswith(vim.uri_from_bufnr(bufnr), "file://") then
        -- Don't attach to buffers such as Fugitive objects
        return
      end

      start_or_attach()
    end,
  })

  vim.api.nvim_create_autocmd("BufReadCmd", {
    group = jdtls_setup,
    pattern = { "jdt://*", "*.class" },
    desc = "Handle jdt:// URIs and classfiles",
    callback = function(args)
      start_or_attach()
      require("jdtls").open_classfile(args.buf, args.match)
    end,
  })

  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_get_current_buf() ~= bufnr and
      vim.api.nvim_buf_is_loaded(bufnr) and
      vim.bo[bufnr].ft == "java" and
      vim.startswith(vim.uri_from_bufnr(bufnr), "file://") then
      vim.api.nvim_create_autocmd("BufEnter", {
        group = jdtls_setup,
        buffer = bufnr,
        desc = "This Java buffer will attach to JDT Language Server once focused",
        once = true,
        callback = start_or_attach,
      })
    end
  end

  vim.api.nvim_create_autocmd("LspAttach", {
    group = jdtls_setup,
    pattern = { "*.java", "jdt://*", "*.class" },
    desc = "JDT Language Server buffer setup",
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)

      if client.name ~= "jdtls" then
        return
      end

      local bufnr = args.buf
      local bufname = args.match

      if vim.fn.exists(":DapContinue") > 0 then
        vim.api.nvim_buf_create_user_command(bufnr, "DapContinue", function()
          require("lbrayner.jdtls.dap").continue()
        end, { nargs = 0 })
      end

      -- Mappings
      local bufopts = { buffer = bufnr }
      vim.keymap.set("n", "gC", M.java_go_to_top_level_declaration, bufopts)
      vim.keymap.set("n", "gY", M.java_type_hierarchy, bufopts)
    end,
  })

  vim.api.nvim_create_autocmd("LspAttach", {
    group = jdtls_setup,
    pattern = "*.java",
    desc = "JDTLS: disable automatic discovery of DAP configuration provider",
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)

      if client.name ~= "jdtls" then return end

      local commands = tbl_get(
        client, "server_capabilities", "executeCommandProvider", "commands"
      )

      if not commands then return end

      if tbl_contains(commands, "vscode.java.startDebugSession") then
        require("jdtls.dap").setup_dap(opts.dap or {})
        local dap = require("dap")

        -- Must run after on_attach (see jdtls.dap.setup.start_or_attach)
        -- From nvim.jdtls.dap's setup_dap_main_class_configs
        if tbl_get(dap, "providers", "configs", "jdtls") then
          -- disable automatic discovery on dap.continue()
          dap.providers.configs.jdtls = nil
        end

        return true -- delete autocmd after performing action
      end
    end,
  })

  vim.api.nvim_create_autocmd("LspAttach", {
    group = jdtls_setup,
    pattern = "*.java",
    desc = "Java Debug: enable debug support on decompiled source",
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)

      if client.name ~= "jdtls" then return end

      local commands = tbl_get(
        client, "server_capabilities", "executeCommandProvider", "commands"
      )

      if not commands then return end

      if tbl_contains(commands, "vscode.java.updateDebugSettings") then
        require("lbrayner.jdtls.dap").enable_debug_support_on_decompiled_source()
        return true -- delete autocmd after performing action
      end
    end,
  })

  start_or_attach()
end

local get_proxy = require("lbrayner").get_proxy_table_for_module

M.operations = get_proxy("lbrayner.jdtls._operations")
M.lib = get_proxy("lbrayner.jdtls._lib")

local function get(proxy, key)
  if not rawget(M, key) then
    rawset(M, key, function(...)
      return proxy[key](...)
    end)
  end
  return rawget(M, key)
end

return setmetatable(M, {
  __index = function(_, key)
    if vim.list_contains(
      {
        "get_current_project_name",
        "with_jdtls",
      },
      key
    )
    then
      return get(M.lib, key)
    end

    return get(M.operations, key)
  end,
  __newindex = function()
    error("Cannot add item")
  end,
})
