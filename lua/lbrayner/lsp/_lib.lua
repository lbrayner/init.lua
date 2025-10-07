local M = {}

function M.on_list(options)
  if vim.tbl_isempty(options.items) then
    vim.notify("Empty list.")
    return
  end

  if #options.items > 1  then
    vim.fn.setqflist({}, " ", options)
    vim.cmd("botright copen")
    return
  end

  local _, qfitem = next(options.items)
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
