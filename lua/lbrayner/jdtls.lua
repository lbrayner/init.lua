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

function M.setup(config)
  local opts = { dap = {} } -- required to setup dap

  local function start_or_attach()
    require("jdtls").start_or_attach(config, opts)
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
      require("jdtls").open_classfile(args.match)
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

  local dap = require("dap")

  vim.api.nvim_create_autocmd("LspAttach", {
    group = jdtls_setup,
    pattern = "*.java",
    desc = "JDT Language Server DAP config override",
    callback = function()
      -- Must run after on_attach (see jdtls.dap.setup.start_or_attach)
      -- From nvim.jdtls.dap's setup_dap_main_class_configs
      if dap.providers and dap.providers.configs and dap.providers.configs.jdtls then
        -- disable the automatic discovery on dap.continue()
        dap.providers.configs.jdtls = nil
        return true -- delete autocmd after overriding jdtls dap provider
      end
    end,
  })

  start_or_attach()
end

M.operations = require("lbrayner").get_proxy_table_for_module("lbrayner.jdtls._operations")

return setmetatable(M, {
  __index = function(_, key)
    if not rawget(M, key) then
      rawset(M, key, function(...)
        return M.operations[key](...)
      end)
    end
  return rawget(M, key)
  end,
  __newindex = function()
    error("Cannot add item")
  end,
})
