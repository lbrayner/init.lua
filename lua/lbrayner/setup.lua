local M = {}

-- fidget.nvim (installed as a dependency of rocks.nvim)

if pcall(require, "fidget") then
  require("fidget").setup()
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
        require("lbrayner.dap").continue()
      end, { nargs = 0 })
    end,
  })

  if vim.v.vim_did_enter == 1 then
    vim.api.nvim_exec_autocmds("VimEnter", { group = dap_custom })
  end
end

-- nvim-dap-ui

function M.dapui()
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

-- tint.nvim

if pcall(require, "tint") then
  require("lbrayner.setup.tint")
end

-- typescript-tools.nvim

function M.typescript_tools()
  local lspconfig_custom = vim.api.nvim_create_augroup("lspconfig_custom", { clear = true })

  vim.api.nvim_create_autocmd("BufNewFile", {
    group = lspconfig_custom,
    desc = "New buffers attach to language servers managed by lspconfig even when autostart is false",
    callback = function(args)
      local bufnr = args.buf
      local bufname = vim.api.nvim_buf_get_name(bufnr)

      vim.schedule(function()
        vim.api.nvim_exec_autocmds("BufRead", { group = "lspconfig", pattern = bufname })
      end)
    end,
  })

  require("typescript-tools").setup({
    autostart = false,
  })
end

return M
