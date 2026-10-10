local nvim_buf_get_mark = vim.api.nvim_buf_get_mark

local M = {}

function M.get_range(opts)
  opts = opts or {}

  if not opts.line1 or not opts.line2 then
    return
  end

  local visual_selection = {
    start = nvim_buf_get_mark(0, "<"),
    ["end"] = nvim_buf_get_mark(0, ">")
  }

  if opts.line1 ~= visual_selection.start[1] or
    opts.line2 ~= visual_selection["end"][1] then
    -- Supplied range inferred
    return {
      start = { opts.line1, 0 },
      ["end"] = { opts.line2, 2147483647 }, -- Maximum line length (vi_diff.txt)
    }
  end

  return visual_selection
end

function M.on_list(opts)
  if vim.tbl_isempty(opts.items) then
    vim.notify("Empty list.")
    return
  end

  if #opts.items > 1  then
    vim.fn.setqflist({}, " ", opts)
    vim.cmd("botright copen")
    return
  end

  local _, qfitem = next(opts.items)
  local filename = qfitem.filename
  local pos = { qfitem.lnum, (qfitem.col - 1) }

  -- From vim.lsp.util.show_document
  -- Push a new item into tagstack
  local from = { vim.fn.bufnr("%"), vim.fn.line("."), vim.fn.col("."), 0 }
  local items = { { tagname = vim.fn.expand("<cword>"), from = from } }
  vim.fn.settagstack(vim.fn.win_getid(), { items = items }, "t")

  local bufnr = vim.fn.bufadd(filename)
  require("lbrayner").jump_to_location(bufnr, pos)
end

return M
