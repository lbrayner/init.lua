local M = {}

function M.get_session()
  -- vim-obsession
  local session = string.gsub(vim.v.this_session, "%.%d+%.obsession~?", "")
  if session ~= "" then
    return vim.fn.fnamemodify(session, ":t:r")
  end
end

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

local function _jump_to_location(win, bufnr, pos)
  -- From vim.lsp.util.show_document
  -- Save position in jumplist
  vim.cmd("normal! m'")

  vim.bo[bufnr].buflisted = true
  vim.api.nvim_win_set_buf(win, bufnr)
  vim.api.nvim_set_current_win(win)
  if pos then
    vim.api.nvim_win_set_cursor(win, pos)
    vim.api.nvim_win_call(win, function()
      -- Open folds under the cursor
      vim.cmd("normal! zv")
    end)
  end
end

function M.jump_to_location(filename, pos)
  local bufnr = vim.fn.bufadd(filename)
  local win = bufwinid(bufnr)

  if not win then
    vim.ui.select({
      { command = "buffer", description = "Current window" },
      { command = "new", description = "Horizontal split" },
      { command = "vnew", description = "Vertical split" },
      { command = "tabnew", description = "Tab" } }, {
      prompt = string.format("Open %s in:", vim.fn.fnamemodify(filename, ":~:.")),
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

      _jump_to_location(win, bufnr, pos)
    end)
    return
  end

  _jump_to_location(win, bufnr, pos)
end

return M
