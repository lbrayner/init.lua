-- Swap | File changes outside
-- https://github.com/neovim/neovim/issues/2127
local buffer_optimization = vim.api.nvim_create_augroup("buffer_optimization", { clear = true })

vim.api.nvim_create_autocmd({ "CursorHold", "BufWritePost", "BufRead", "BufLeave" }, {
  group = buffer_optimization,
  desc = "Setting swapfile flag to trigger SwapExists",
  callback = function(args)
    local bufnr = args.buf
    if vim.bo[bufnr].buftype == "" then
      vim.bo[bufnr].swapfile = vim.bo[bufnr].modified
    end
  end,
})

vim.api.nvim_create_autocmd("SwapExists", {
  group = buffer_optimization,
  desc = "Automatically delete old swap files",
  callback = function(args)
    -- if swapfile is older than file itself, just get rid of it
    if vim.fn.getftime(vim.v.swapname) < vim.fn.getftime(args.file) then
      vim.fn.delete(vim.v.swapname)
      vim.v.swapchoice = "e"
    end
  end,
})

-- Check if file was modified outside this instance
local checktime = vim.api.nvim_create_augroup("checktime", { clear = true })
vim.api.nvim_create_autocmd("VimEnter", {
  group = checktime,
  desc = "Wipe buffers without files on session load",
  callback = function()
    vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "VimResume" }, {
      group = checktime,
      callback = function()
        if vim.fn.getcmdwintype() == "" then -- E11: Invalid in command line window
          vim.cmd.checktime()
        end
      end,
    })
  end,
})
if vim.v.vim_did_enter == 1 then
  vim.api.nvim_exec_autocmds("VimEnter", { group = checktime })
end
