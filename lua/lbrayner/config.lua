-- fidget.nvim

-- Standalone UI for nvim-lsp progress. Eye candy for the impatient.
-- Installed as a dependency of rocks.nvim
require("fidget").setup({
  notification = {
    window = {
      winblend = 0, -- to fix the interaction with transparent backgrounds
    },
  },
})

-- Improved alternate file mapping
vim.keymap.set("n", "<Space>a", function()
  local alternate = vim.fn.bufnr("#")
  if alternate > 0 and vim.api.nvim_buf_is_valid(alternate) then
    local name = vim.fn.pathshorten(require("lbrayner.path").full_path())
    vim.api.nvim_set_current_buf(alternate)
    require("lbrayner.flash").flash_window()
    require("fidget").notify(string.format("Switched to alternate buffer. Previous buffer was %s.", name))
  else
    vim.notify("Alternate buffer is not valid.")
  end
end)

-- fzf-lua

if pcall(require, "fzf-lua") then
  require("lbrayner.config.fzf-lua")
end

-- lir.nvim

if pcall(require, "lir") then
  require("lbrayner.config.lir")
end

-- mini.nvim

if pcall(require, "mini.align") then
  require("lbrayner.config.mini")
end

-- neosolarized.nvim

if pcall(require, "neosolarized") then
  require("lbrayner.config.neosolarized")
end

-- nvim-colorizer.lua

if pcall(require, "colorizer") then
  require("colorizer").setup()
end

-- nvim-dap-ui

if pcall(require, "dapui") then
  require("lbrayner.config.dap")
end

-- nvim-jdtls (git: lbrayner/nvim-jdtls, lbrayner)

if pcall(require, "jdtls") and pcall(require, "lspconfig") then
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
end

-- nvim-lspconfig

if pcall(require, "lspconfig") then
  -- Lua
  -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#lua_ls
  require("lspconfig").lua_ls.setup({
    autostart = false,
    capabilities = require("lbrayner.lsp").default_capabilities(),
    settings = {
      Lua = {
        runtime = {
          -- Tell the language server which version of Lua you"re using (most
          -- likely LuaJIT in the case of Neovim)
          version = "LuaJIT",
        },
        diagnostics = {
          -- Get the language server to recognize the `vim` global
          globals = { "vim" },
        },
        workspace = {
          -- Make the server aware of Neovim runtime files
          library = vim.api.nvim_get_runtime_file("", true),
        },
        -- Do not send telemetry data containing a randomized but unique
        -- identifier
        telemetry = {
          enable = false,
        },
      },
    },
  })

  require("lbrayner.config.lsp")
end

-- nvim-jdtls: skipping autocmds and commands
vim.g.nvim_jdtls = 1

-- nvim-snippy

if pcall(require, "snippy") then
  require("lbrayner.config.lsp-completion")
end

-- nvim-spider

if pcall(require, "spider") then
  local function spider(motion)
    return function() require("spider").motion(motion) end
  end

  vim.keymap.set({"n", "o", "x"}, "<Leader>w",  spider("w"),  { desc = "Spider-w"  })
  vim.keymap.set({"n", "o", "x"}, "<Leader>e",  spider("e"),  { desc = "Spider-e"  })
  vim.keymap.set({"n", "o", "x"}, "<Leader>b",  spider("b"),  { desc = "Spider-b"  })
  vim.keymap.set({"n", "o", "x"}, "<Leader>ge", spider("ge"), { desc = "Spider-ge" })
end

-- tint.nvim

if pcall(require, "tint") then
  require("lbrayner.config.tint")
end

-- typescript-tools.nvim

if pcall(require, "typescript-tools") then
  require("typescript-tools").setup({
    autostart = false,
    capabilities = require("lbrayner.lsp").default_capabilities(),
  })
end
