local M = {}

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

if not pcall(require, "lz.n") then
  -- rocks.nvim wasn't synced at least once
  return M
end

require("dap-view").setup({ winbar = { default_section = "scopes" } })
require("fidget").setup() -- fidget.nvim (installed as a dependency of rocks.nvim)
require("lbrayner.setup.dap") -- nvim-dap
require("lbrayner.setup.lir") -- lir.nvim
require("lbrayner.setup.lz") -- lz.n
require("lbrayner.setup.mini") -- mini.nvim
require("lbrayner.setup.neosolarized") -- neosolarized.nvim
require("lbrayner.setup.tint") -- tint.nvim
require("nvim-highlight-colors").setup({ -- nvim-highlight-colors
  enable_hsl_without_function = false
})

-- nvim-jdtls

vim.g.nvim_jdtls = 1 -- skipping autocmds and commands
require("lbrayner.jdtls").create_user_command()

return M
