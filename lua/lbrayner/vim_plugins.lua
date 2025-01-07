-- reply.vim
vim.api.nvim_create_user_command("ReplFile", [[call reply#command#send(join(getline(1,line("$")),"\n"),0,0)]], {
  nargs = 0 })

-- vim-characterize

vim.keymap.set("n", "<F13>", "<Plug>(characterize)", { remap = true })
vim.api.nvim_create_user_command("Characterize", [[exe "normal \<F13>"]], { nargs = 0 })

-- vim-dadbod
require("lbrayner.database")

-- vim-fugitive

local fugitive_setup = vim.api.nvim_create_augroup("fugitive_setup", { clear = true })

vim.api.nvim_create_autocmd("SourcePost", {
  pattern = "*/plugin/fugitive.vim",
  group = fugitive_setup,
  desc = "Fugitive setup",
  callback = function()
    require("lbrayner.fugitive").setup()
  end,
})

-- vim-quickhl

vim.keymap.set("n", "<Space>m", "<Plug>(quickhl-manual-this)", { remap = true })
vim.keymap.set("x", "<Space>m", "<Plug>(quickhl-manual-this)", { remap = true })
vim.keymap.set("n", "<Space>M", "<Plug>(quickhl-manual-reset)", { remap = true })
vim.keymap.set("x", "<Space>M", "<Plug>(quickhl-manual-reset)", { remap = true })

vim.keymap.set("n", "<Space>w", "<Plug>(quickhl-manual-this-whole-word)", { remap = true })
vim.keymap.set("x", "<Space>w", "<Plug>(quickhl-manual-this-whole-word)", { remap = true })

vim.keymap.set("n", "<Space>c", "<Plug>(quickhl-manual-clear)", { remap = true })
vim.keymap.set("v", "<Space>c", "<Plug>(quickhl-manual-clear)", { remap = true })

-- vim-rsi

-- vim-rsi's M-d is not at parity with readline's M-d
-- Case matters for keys after alt or meta

local vim_rsi_override = vim.api.nvim_create_augroup("vim_rsi_override", { clear = true })

vim.api.nvim_create_autocmd("VimEnter", {
  group = vim_rsi_override,
  desc = "Override vim-rsi mappings",
  callback = function()
    vim.keymap.set("c", "<M-d>", "<C-F>ea<C-W><C-C>")
  end,
})

if vim.v.vim_did_enter == 1 then
  vim.api.nvim_exec_autocmds("VimEnter", { group = vim_rsi_override })
end

-- vim-rzip
vim.g.rzipPlugin_extra_ext = "*.odt"
