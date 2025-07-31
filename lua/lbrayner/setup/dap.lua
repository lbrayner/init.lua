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
