local M = {}

-- From vim.lsp.util.bufwinid
local function bufwinid(bufnr)
  local win = vim.fn.bufwinid(bufnr)
  if win > 0 then return win end
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == bufnr then
      return win
    end
  end
end

local function go_to_result(win, bufnr, qfitem)
  -- From vim.lsp.util.show_document
  -- Save position in jumplist
  vim.cmd("normal! m'")
  -- Push a new item into tagstack
  local from = { vim.fn.bufnr("%"), vim.fn.line("."), vim.fn.col("."), 0 }
  local items = { { tagname = vim.fn.expand("<cword>"), from = from } }
  vim.fn.settagstack(vim.fn.win_getid(), { items = items }, "t")

  vim.bo[bufnr].buflisted = true
  vim.api.nvim_win_set_buf(win, bufnr)
  vim.api.nvim_set_current_win(win)
  vim.api.nvim_win_set_cursor(win, { qfitem.lnum, (qfitem.col - 1) })
  vim.api.nvim_win_call(win, function()
    -- Open folds under the cursor
    vim.cmd("normal! zv")
  end)
end

function M.on_list(options)
  if #options.items > 1  then
    vim.fn.setqflist({}, " ", options)
    vim.cmd("botright copen")
    return
  end

  local qfitem = options.items[1]
  local bufnr = vim.fn.bufadd(qfitem.filename)
  local win = bufwinid(bufnr)

  if not win then
    vim.ui.select({
      { command = "edit", description = "Current window" },
      { command = "new", description = "Horizontal split" },
      { command = "vnew", description = "Vertical split" },
      { command = "tabnew", description = "Tab" } }, {
      prompt = string.format("Open the only result (%s) in:",
        vim.fn.fnamemodify(qfitem.filename, ":.")),
      format_item = function(open_cmd) return open_cmd.description end,
    }, function(open_cmd)
      if not open_cmd then
        return
      end

      -- From vim.lsp.util.create_window_without_focus
      local prev = vim.api.nvim_get_current_win()
      vim.cmd(open_cmd.command)
      win = vim.api.nvim_get_current_win()
      vim.api.nvim_set_current_win(prev)

      go_to_result(win, bufnr, qfitem)
    end)
    return
  end

  go_to_result(win, bufnr, qfitem)
end

return M
