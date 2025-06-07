local M = {}

-- fidget.nvim (installed as a dependency of rocks.nvim)

if pcall(require, "fidget") then
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
      require("fidget").notify(string.format("Switched to alternate buffer. Previous buffer was %s.", name))
    else
      vim.notify("Alternate buffer is not valid.")
    end
  end)
end

-- fzf-lua

if pcall(require, "fzf-lua") then
  require("lbrayner.setup.fzf-lua")
end

-- lir.nvim

if pcall(require, "lir") then
  require("lbrayner.setup.lir")
end

-- mini.nvim

if pcall(require, "mini.align") then
  require("lbrayner.setup.mini")
end

-- neosolarized.nvim

if pcall(require, "neosolarized") then
  require("lbrayner.setup.neosolarized")
end

-- nvim-colorizer.lua

if pcall(require, "colorizer") then
  require("colorizer").setup()
end

-- nvim-dap
if pcall(require, "dap") then
  local dap_custom = vim.api.nvim_create_augroup("dap_custom", { clear = true })

  -- Redefine DapContinue
  vim.api.nvim_create_autocmd("VimEnter", {
    group = dap_custom,
    once = true,
    callback = function()
      vim.api.nvim_create_user_command("DapContinue", function()
        require("dap").continue({
          before = function(config)
            local success, session = pcall(require, "lbrayner.session")

            if success and session.dap_run_before and type(session.dap_run_before) == "function" then
              config = session.dap_run_before(config)
            end

            return config
          end
        })
      end, { nargs = 0 })
    end,
  })

  if vim.v.vim_did_enter == 1 then
    vim.api.nvim_exec_autocmds("VimEnter", { group = dap_custom })
  end
end

-- nvim-dap-ui

if pcall(require, "dapui") then
  require("dapui").setup()

  vim.api.nvim_create_user_command("DapUiClose", function(command)
    require("dapui").close({ layout = tonumber(command.args) })
  end, { nargs = "?" })

  vim.api.nvim_create_user_command("DapUiOpen", function(command)
    require("dapui").open({ layout = tonumber(command.args) })
  end, { nargs = "?" })

  vim.api.nvim_create_user_command("DapUiReset", require("dapui").setup, { nargs = 0 })

  vim.api.nvim_create_user_command("DapUiToggle", function(command)
    require("dapui").toggle({ layout = tonumber(command.args) })
  end, { nargs = "?" })
end

-- nvim-highlight-colors

if pcall(require, "nvim-highlight-colors") then
  require("nvim-highlight-colors").setup({ enable_hsl_without_function = false })
end

-- nvim-jdtls

vim.g.nvim_jdtls = 1 -- skipping autocmds and commands
require("lbrayner.jdtls").create_user_command()

-- nvim-lspconfig

if pcall(require, "lspconfig") then
  -- Lua
  -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#lua_ls
  require("lspconfig").lua_ls.setup({
    autostart = false,
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
end

-- tint.nvim

if pcall(require, "tint") then
  require("lbrayner.setup.tint")
end

-- typescript-tools.nvim

function M.typescript_tools()
  require("typescript-tools").setup({
    autostart = false,
  })
end

return M
