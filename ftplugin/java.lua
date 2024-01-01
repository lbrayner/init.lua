vim.api.nvim_buf_create_user_command(0, "JdtStart", function(command)
  local config
  local success, session = pcall(require, "lbrayner.session.jdtls")

  if success then
    config = session.get_config()
  else
    config = require("lbrayner.jdtls").get_config()
  end

  local client = vim.lsp.get_clients({ name = "jdtls" })[1]

  if not command.bang and client then
    require("jdtls").start_or_attach(config)
    return
  end

  local jdtls_setup = vim.api.nvim_create_augroup("jdtls_setup", { clear = true })

  vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    group = jdtls_setup,
    pattern = "*.java",
    desc = "New Java buffers attach to jdtls",
    callback = function(args)
      local bufname = args.match

      if vim.fn.filereadable(bufname) == 0 then
        return
      end

      require("jdtls").start_or_attach(config)
    end,
  })

  vim.api.nvim_create_autocmd("BufReadCmd", {
    group = jdtls_setup,
    pattern = { "jdt://*", "*.class" },
    desc = "Handle jdt:// URIs and classfiles",
    callback = function(args)
      require("jdtls").start_or_attach(config)
      require("jdtls").open_classfile(args.match)
    end,
  })

  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_get_current_buf() ~= bufnr and
      vim.api.nvim_buf_is_loaded(bufnr) and
      vim.bo[bufnr].ft == "java" and
      vim.fn.filereadable(vim.api.nvim_buf_get_name(bufnr)) == 1 and
      (not client or not vim.lsp.buf_is_attached(bufnr, client.id)) then
      vim.api.nvim_create_autocmd("BufEnter", {
        group = jdtls_setup,
        buffer = bufnr,
        desc = "This Java buffer will attach to jdtls once focused",
        once = true,
        callback = function()
          require("jdtls").start_or_attach(config)
        end,
      })
    end
  end

  local function java_type_hierarchy()
    require("lbrayner.jdtls").java_type_hierarchy({
      on_list = require("lbrayner.lsp").on_list,
      reuse_win = true
    })
  end

  vim.api.nvim_create_autocmd("LspAttach", {
    group = jdtls_setup,
    pattern = { "*.java", "jdt://*", "*.class" },
    desc = "jdtls buffer setup",
    callback = function(args)
      local bufnr = args.buf
      local bufname = args.match

      if vim.fn.filereadable(bufname) == 0 and not vim.startswith(bufname, "jdt://") then
        return
      end

      -- Mappings
      local bufopts = { buffer = bufnr }
      vim.keymap.set("n", "gC", require("lbrayner.jdtls").java_go_to_top_level_declaration, bufopts)
      vim.keymap.set("n", "gY", java_type_hierarchy, bufopts)

      -- Custom statusline
      if vim.endswith(bufname, ".java") then
        vim.b[bufnr].Statusline_custom_leftline = '%<%{expand("%:t:r")} ' ..
          "%{v:lua.require'lbrayner.statusline'.status_flag()}"
        vim.b[bufnr].Statusline_custom_mod_leftline = '%<%1*%{expand("%:t:r")}' ..
          " %{v:lua.require'lbrayner.statusline'.status_flag()}%*"
        if vim.api.nvim_get_current_buf() == bufnr then
          vim.cmd("silent! doautocmd <nomodeline> User CustomStatusline")
        end
      end

      -- Commands
      vim.api.nvim_buf_create_user_command(bufnr, "JdtGoToTopLevelDeclaration",
        require("lbrayner.jdtls").java_go_to_top_level_declaration, { nargs = 0 })
      vim.api.nvim_buf_create_user_command(bufnr, "JdtOrganizeImports", require("jdtls").organize_imports, {
        nargs = 0
      })
      vim.api.nvim_buf_create_user_command(bufnr, "JdtStop", function(_command)
        local client = vim.lsp.get_clients({ name = "jdtls" })[1]
        if not client then return end
        vim.api.nvim_del_augroup_by_name("jdtls_setup")
        vim.lsp.stop_client(client.id)
      end, { nargs = 0 })
      vim.api.nvim_buf_create_user_command(bufnr, "JdtTestClass", require("jdtls").test_class, { nargs = 0 })
      vim.api.nvim_buf_create_user_command(bufnr, "JdtTestNearestMethod", require("jdtls").test_nearest_method, {
        nargs = 0 })
      vim.api.nvim_buf_create_user_command(bufnr, "JdtTypeHierarchy", java_type_hierarchy, {
        nargs = 0
      })
    end,
  })

  local jdtls_undo = vim.api.nvim_create_augroup("jdtls_undo", { clear = true })

  vim.api.nvim_create_autocmd("LspDetach", {
    group = jdtls_undo,
    pattern = "*.java",
    desc = "Undo jdtls buffer setup",
    callback = function(args)
      local bufnr = args.buf

      -- Restore the statusline
      vim.b[bufnr].Statusline_custom_leftline = nil
      vim.b[bufnr].Statusline_custom_mod_leftline = nil

      -- Delete user commands
      for _, command in ipairs({
        "JdtGoToTopLevelDeclaration",
        "JdtOrganizeImports",
        "JdtStop",
        "JdtTypeHierarchy",
        "JdtCompile",
        "JdtSetRuntime",
        "JdtUpdateConfig",
        "JdtJol",
        "JdtBytecode",
        "JdtJshell",
        "JdtRestart",
        "JdtUpdateDebugConfig",
        "JdtUpdateHotcode" }) do
        pcall(vim.api.nvim_buf_del_user_command, bufnr, command) -- Ignore error if command doesn't exist
      end
    end,
  })

  require("jdtls").start_or_attach(config)
end, { bang = true, desc = "Start jdtls and setup automatic attach, local buffer configuration", nargs = 0 })
