local nvim_buf_create_user_command = vim.api.nvim_buf_create_user_command

local function jdtls_create_commands(bufnr)
  nvim_buf_create_user_command(bufnr, "JdtStop", function(_command)
    local client = vim.lsp.get_active_clients({ name="jdtls" })[1]
    if not client then
      return
    end
    vim.api.nvim_del_augroup_by_name("jdtls_setup")
    vim.lsp.stop_client(client.id)
  end, { nargs=0 })
  -- The following are commands from the nvim-jdtls README
  nvim_buf_create_user_command(bufnr, "JdtCompile", function(command)
    require("jdtls").compile(command.fargs)
  end, { complete="custom,v:lua.require'jdtls'._complete_compile", nargs="?" })
  nvim_buf_create_user_command(bufnr, "JdtSetRuntime", function(command)
    require("jdtls").set_runtime(command.fargs)
  end, { complete="custom,v:lua.require'jdtls'._complete_set_runtime", nargs="?" })
  nvim_buf_create_user_command(bufnr, "JdtUpdateConfig", require("jdtls").update_project_config, {
    nargs=0
  })
  nvim_buf_create_user_command(bufnr, "JdtJol", require("jdtls").jol, { nargs=0 })
  nvim_buf_create_user_command(bufnr, "JdtBytecode", require("jdtls").javap, { nargs=0 })
  nvim_buf_create_user_command(bufnr, "JdtJshell", require("jdtls").jshell, { nargs=0 })
  nvim_buf_create_user_command(bufnr, "JdtOrganizeImports", require("jdtls").organize_imports, {
    nargs=0
  })
end

nvim_buf_create_user_command(0, "JdtStart", function(_command)
  local config
  local success, session = pcall(require, "lbrayner.session.jdtls")

  if success then
    config = session.get_config()
  else
    config = require("lbrayner.jdtls").get_config()
  end

  if vim.lsp.get_active_clients({ name="jdtls" })[1] then
    return require("jdtls").start_or_attach(config)
  end

  local jdtls_setup = vim.api.nvim_create_augroup("jdtls_setup", { clear=true })

  vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    group = jdtls_setup,
    pattern = config.root_dir .. "/*.java",
    desc = "New Java buffers attach to jdtls",
    callback = function()
      require("jdtls").start_or_attach(config)
    end,
  })

  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_get_current_buf() ~= bufnr and
      vim.api.nvim_buf_is_loaded(bufnr) and
      vim.bo[bufnr].ft == "java" and
      vim.startswith(vim.api.nvim_buf_get_name(bufnr), config.root_dir) then
      vim.api.nvim_create_autocmd({ "BufEnter" }, {
        group = jdtls_setup,
        buffer = bufnr,
        desc = "This Java buffer will attach to jdtls once focused",
        once = true,
        callback = function(_args)
          require("jdtls").start_or_attach(config)
        end,
      })
    end
  end

  vim.api.nvim_create_autocmd("LspAttach", {
    group = jdtls_setup,
    pattern = config.root_dir .. "/*.java",
    desc = "jdtls buffer setup",
    callback = function(args)
      local bufnr = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      -- TODO disabling semantic highlighting for now
      client.server_capabilities.semanticTokensProvider = nil

      -- Mapping overrides
      local bufopts = { buffer=bufnr }
      -- Go to class declaration
      vim.keymap.set("n","gD", function()
        vim.api.nvim_win_set_cursor(0, {1, 0})
        if vim.fn.search(
          "\\v^public\\s+%(abstract\\s+)?%(final\\s+)?%(class|enum|interface)\\s+\\zs" ..
          vim.fn.expand("%:t:r")) > 0 then
          vim.cmd "normal! zz"
        end
      end, bufopts)

      -- Custom statusline
      vim.b[bufnr].Statusline_custom_leftline = '%<%{expand("%:t:r")} ' ..
      '%{statusline#StatusFlag()}'
      vim.b[bufnr].Statusline_custom_mod_leftline = '%<%1*%{expand("%:t:r")}' ..
      ' %{statusline#StatusFlag()}%*'

      -- Setup buffer local commands
      jdtls_create_commands(bufnr)
    end,
  })

  local jdtls_undo = vim.api.nvim_create_augroup("jdtls_undo", { clear=true })

  vim.api.nvim_create_autocmd("LspDetach", {
    group = jdtls_undo,
    pattern = config.root_dir .. "/*.java",
    desc = "Undo jdtls buffer setup",
    callback = function(args)
      local bufnr = args.buf

      -- Restore the statusline
      vim.b[bufnr].Statusline_custom_leftline = nil
      vim.b[bufnr].Statusline_custom_mod_leftline = nil

      -- Delete user commands
      for _, command in ipairs({
        "JdtStop",
        "JdtCompile",
        "JdtSetRuntime",
        "JdtUpdateConfig",
        "JdtJol",
        "JdtBytecode",
        "JdtJshell",
        "JdtOrganizeImports" }) do
        vim.api.nvim_buf_del_user_command(bufnr, command)
      end
    end,
  })

  require("jdtls").start_or_attach(config)
end, { desc="Start jdtls and setup automatic attach, local buffer configuration", nargs=0 })
