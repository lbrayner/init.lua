local startswith = vim.startswith
local terminal_autocmd

vim.api.nvim_create_autocmd("SessionLoadPre", {
  desc = "Lazily restore terminal buffers",
  once = true,
  callback = function()
    local autocmds = vim.api.nvim_get_autocmds({
      group = "nvim.terminal",
      event = "BufReadCmd",
      pattern = "term://*",
    })

    assert(#autocmds == 1, "There should be just one nvim.terminal BufReadCmd autocmd")

    terminal_autocmd = autocmds[1]

    vim.api.nvim_del_autocmd(terminal_autocmd.id)

    terminal_autocmd.on_demand_setup_id = vim.api.nvim_create_autocmd("BufReadCmd", {
      pattern = "term://*",
      callback = function(args)
        local bufnr = args.buf

        vim.bo[bufnr].filetype = "lazyterm"

        vim.api.nvim_create_autocmd("InsertEnter", {
          buffer = bufnr,
          once = true,
          desc = "Restore terminal buffer after entering Insert mode",
          callback = vim.schedule_wrap(function()
            vim.api.nvim_exec_autocmds("BufReadCmd", {
              group = terminal_autocmd.group,
              buf = bufnr,
            })
          end),
        })
      end,
    })
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  desc = "Session configuration",
  once = true,
  callback = function()
    if vim.v.this_session == "" then return end

    vim.api.nvim_del_autocmd(terminal_autocmd.on_demand_setup_id)

    vim.api.nvim_create_autocmd("BufReadCmd", {
      group = terminal_autocmd.group,
      pattern = terminal_autocmd.pattern,
      callback = terminal_autocmd.callback,
      command = terminal_autocmd.command,
      nested = true, -- value not in terminal_autocmd
      desc = terminal_autocmd.desc,
    })

    require("lbrayner.wipe").loop_buffers(true, function(buf) -- BWipeNotReadable!
      return (
        not startswith(buf.name, "fugitive://") and
        not startswith(buf.name, "jdt://") and
        buf.listed == 1 and
        vim.bo[buf.bufnr].filetype ~= "lazyterm" and
        not vim.uv.fs_stat(buf.name)
      )
    end)

    pcall(vim.cmd.exe, [["normal! \<C-W>="]]) -- Equalize windows
  end,
})

local terminal_setup = vim.api.nvim_create_augroup("terminal_setup", { clear = true })

vim.api.nvim_create_autocmd("TermOpen", {
  group = terminal_setup,
  desc = "Terminal filetype",
  callback = function()
    if vim.v.vim_did_enter == 0 or -- session restore
      vim.b.default_filetype or
      vim.bo.filetype == "lazyterm" or
      vim.bo.filetype == "" then -- buffer created in background, BufEnter not triggered
      vim.bo.filetype = "terminal"
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "terminal",
  group = terminal_setup,
  desc = "Fix terminal title and set keymaps",
  callback = function(args)
    local bufnr = args.buf

    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(bufnr) then
        return
      end

      -- Find first window in current tab visiting this buffer
      local winid = vim.fn.win_findbuf(bufnr)[1]

      -- Specifically trying to exclude fzf buffers
      if vim.bo[bufnr].filetype == "terminal" and winid == vim.api.nvim_get_current_win() then
        vim.wo.relativenumber = true
      end

      local bufname = vim.api.nvim_buf_get_name(bufnr)
      local term_title = vim.b[bufnr].term_title

      if startswith(term_title, "reply: ") then
        local reply = string.format(
          "%s (%d)", term_title, vim.fn.jobpid(vim.bo[bufnr].channel)
        )
        vim.api.nvim_buf_set_name(bufnr, reply)
      elseif startswith(bufname, "term://") and
        startswith(term_title, "term://") and bufname ~= term_title then
        vim.api.nvim_buf_set_name(bufnr, term_title)
        local wrong_title_bufnr = vim.fn.bufnr(bufname)
        vim.api.nvim_buf_delete(wrong_title_bufnr, { force = true })
      end

      vim.keymap.set("n", "<A-h>", [[<C-\><C-N><C-W>h]], { buffer = bufnr })
      vim.keymap.set("n", "<A-j>", [[<C-\><C-N><C-W>j]], { buffer = bufnr })
      vim.keymap.set("n", "<A-k>", [[<C-\><C-N><C-W>k]], { buffer = bufnr })
      vim.keymap.set("n", "<A-l>", [[<C-\><C-N><C-W>l]], { buffer = bufnr })
    end)
  end,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
  pattern = "term://*",
  group = terminal_setup,
  desc = "Line numbers are not helpful in terminal buffers",
  callback = function()
    vim.wo.number = false
  end,
})

vim.api.nvim_create_autocmd("TermEnter", {
  group = terminal_setup,
  callback = function()
    if not require("lbrayner").win_is_floating() then
      local terminals = vim.tbl_filter(function(winid)
        local bufnr = vim.api.nvim_win_get_buf(winid)
        return vim.bo[bufnr].buftype == "terminal"
      end, vim.api.nvim_tabpage_list_wins(0))

      if vim.tbl_count(terminals) > 1 then
        vim.opt.winhighlight:append({ Normal = "CursorLine" })
      end
    end
  end,
})

vim.api.nvim_create_autocmd("TermLeave", {
  group = terminal_setup,
  callback = function()
    vim.opt.winhighlight:remove({ "Normal" })
  end,
})

if vim.v.vim_did_enter == 1 then
  vim.api.nvim_exec_autocmds("VimEnter", { group = terminal_setup })
end
