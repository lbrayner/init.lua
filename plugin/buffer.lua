-- Swap | File changes outside
-- https://github.com/neovim/neovim/issues/2127
local buffer_optimization = vim.api.nvim_create_augroup("buffer_optimization", { clear = true })

vim.api.nvim_create_autocmd({ "BufLeave", "BufRead", "BufWritePost", "CursorHold" }, {
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

local checktime = vim.api.nvim_create_augroup("checktime", { clear = true })

vim.api.nvim_create_autocmd("VimEnter", {
  group = checktime,
  callback = function()
    vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "VimResume" }, {
      group = checktime,
      desc = "Check if file was modified outside this instance",
      callback = function()
        if vim.fn.getcmdwintype() == "" then -- E11: Invalid in command line window
          vim.cmd.checktime()
        end
      end,
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = "FugitiveChanged",
      group = checktime,
      desc = "Check if file was modified by an asynchronous fugitive job",
      callback = function()
        if vim.fn.getcmdwintype() == "" then -- E11: Invalid in command line window
          local fugitive_result = vim.fn.FugitiveResult()
          if fugitive_result.capture_bufnr and type(fugitive_result.capture_bufnr) == "number" then
            vim.cmd.checktime()
          end
        end
      end,
    })
  end,
})

if vim.v.vim_did_enter == 1 then
  vim.api.nvim_exec_autocmds("VimEnter", { group = checktime })
end

local large_file = vim.api.nvim_create_augroup("large_file", { clear = true })

vim.api.nvim_create_autocmd("Syntax", {
  pattern = { "json", "html", "xml" },
  group = large_file,
  desc = "Disable syntax for large files",
  callback = function(args)
    local bufnr = args.buf
    local size = tonumber(vim.fn.wordcount()["bytes"])

    if size > 1024 * 512 then
      vim.schedule(function()
        -- Buffer might be gone
        if vim.api.nvim_buf_is_valid(bufnr) then
          vim.bo[bufnr].syntax = "large_file"
        end
      end)

      -- Folds are slow
      -- There are vim-fugitive mappings that open windows and tabs
      vim.api.nvim_create_autocmd("WinEnter", {
        buffer = bufnr,
        once = true,
        callback = function()
          vim.schedule(function()
            vim.cmd("normal! zR") -- Open all folds
          end)
        end,
      })
    end
  end,
})
