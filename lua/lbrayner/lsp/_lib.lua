local M = {}

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
