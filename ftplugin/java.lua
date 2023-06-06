vim.api.nvim_buf_create_user_command(0, "JdtStart", function(command)
  local config
  local success, session = pcall(require, "lbrayner.session.jdtls")

  if success then
    config = session.get_config()
  else
    config = require("lbrayner.jdtls").get_config()
  end

  local client = vim.lsp.get_active_clients({ name="jdtls" })[1]

  if not command.bang and client then
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

  vim.api.nvim_create_autocmd("BufReadCmd", {
    group = jdtls_setup,
    pattern = { "jdt://*", "*.class" },
    desc = "Handle jdt:// URIs and classfiles",
    callback = function(command)
      require("jdtls").start_or_attach(config)
      require("jdtls").open_classfile(command.match)
    end,
  })

  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_get_current_buf() ~= bufnr and
      vim.api.nvim_buf_is_loaded(bufnr) and
      vim.bo[bufnr].ft == "java" and
      vim.startswith(vim.api.nvim_buf_get_name(bufnr), config.root_dir) and
      (not client or not vim.lsp.buf_is_attached(bufnr, client.id)) then
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

      if vim.tbl_get(args, "data") then
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        -- TODO disabling semantic highlighting for now
        client.server_capabilities.semanticTokensProvider = nil
      end

      -- Mapping overrides
      local bufopts = { buffer=bufnr }
      -- Open type hierarchy
      if require("jdtls").java_open_type_hierarchy then
        vim.keymap.set("n", "gD", function()
          require("jdtls").java_open_type_hierarchy(10, true)
        end, bufopts)
      end
      -- Go to class declaration
      vim.keymap.set("n", "gC", function()
        -- Go to the first line, first column
        local line_col = vim.api.nvim_win_get_cursor(0)
        -- Add current position to the jump list
        vim.cmd("normal! " .. line_col[1] .. "G")
        vim.api.nvim_win_set_cursor(0, {1, 0})
        if vim.fn.search(
          "\\v%(public\\s+)?%(abstract|final\\s+)?%(class|enum|interface)\\s+\\zs" ..
          vim.fn.expand("%:t:r")) > 0 then
          vim.cmd "normal! zz"
        else
          -- Restores cursor by popping the jump list
          vim.cmd("exe \"normal! \\<C-O>\"")
        end
      end, bufopts)

      -- Custom statusline
      vim.b[bufnr].Statusline_custom_leftline = '%<%{expand("%:t:r")} ' ..
      '%{statusline#StatusFlag()}'
      vim.b[bufnr].Statusline_custom_mod_leftline = '%<%1*%{expand("%:t:r")}' ..
      ' %{statusline#StatusFlag()}%*'

      -- Setup buffer local commands
      vim.api.nvim_buf_create_user_command(bufnr, "JdtStop", function(_command)
        local client = vim.lsp.get_active_clients({ name="jdtls" })[1]
        if not client then
          return
        end
        vim.api.nvim_del_augroup_by_name("jdtls_setup")
        vim.lsp.stop_client(client.id)
      end, { nargs=0 })
      vim.api.nvim_buf_create_user_command(bufnr, "JdtOrganizeImports", require("jdtls").organize_imports, {
        nargs=0
      })

      require("jdtls.setup").add_commands()
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
        "JdtOrganizeImports",
        "JdtCompile",
        "JdtSetRuntime",
        "JdtUpdateConfig",
        "JdtJol",
        "JdtBytecode",
        "JdtJshell",
        "JdtRestart" }) do
        if vim.api.nvim_buf_get_commands(bufnr, {})[command] then
          vim.api.nvim_buf_del_user_command(bufnr, command)
        end
      end
    end,
  })

  require("jdtls").start_or_attach(config)
end, { bang=true, desc="Start jdtls and setup automatic attach, local buffer configuration", nargs=0 })
