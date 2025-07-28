local M = {}

-- fidget.nvim (installed as a dependency of rocks.nvim)

if pcall(require, "fidget") then
  require("fidget").setup()
end

-- fzf-lua

do
  local keymap = require("lz.n").keymap({
    "fzf-lua",
    after = function()
      require("lbrayner.setup.fzf-lua")
    end,
  })

  local opts = { silent = true }

  keymap.set("n", "<F1>", function()
    require("lbrayner.fzf-lua").help_tags()
  end, opts)
  keymap.set("n", "<F4>", function()
    require("lbrayner.fzf-lua").file_marks()
  end, opts)
  keymap.set("n", "<F5>", function()
    require("lbrayner.fzf-lua").buffers()
  end, opts)
  keymap.set("n", "<Leader><F7>", function()
    require("lbrayner.fzf-lua").files_clear_cache()
  end, opts)
  keymap.set("n", "<F7>", function()
    require("lbrayner.fzf-lua").files()
  end, opts)
  keymap.set("n", "<F8>", function()
    require("lbrayner.fzf-lua").tabs()
  end, opts)
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

require("lz.n").load({
  "nvim-dap-ui",
  after = function()
    require("lbrayner.dapui").create_user_commands()
    require("dapui").setup()
  end,
  cmd = "DapUiToggle",
})

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
