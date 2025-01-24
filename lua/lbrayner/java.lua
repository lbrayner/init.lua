-- nvim-jdtls: skipping autocmds and commands
vim.g.nvim_jdtls = 1

local jdtls_start = vim.api.nvim_create_augroup("jdtls_start", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  group = jdtls_start,
  callback = function(args)
    local bufnr = args.buf

    vim.api.nvim_buf_create_user_command(bufnr, "JdtStart", function(command)
      local config
      local opts = {}
      local success, session = pcall(require, "lbrayner.session.jdtls")

      if success then
        config = session.get_config()
        opts = session.get_opts()
      else
        config = require("lbrayner.jdtls").get_config()
      end

      local client = vim.lsp.get_clients({ name = "jdtls" })[1]

      if not command.bang and client then
        require("jdtls").start_or_attach(config)
        return
      end

      require("lbrayner.jdtls").setup(config, opts)
    end,
    {
      bang = true,
      desc = "Start jdtls and setup automatic attach, local buffer configuration",
      nargs = 0
    })
  end,
})
