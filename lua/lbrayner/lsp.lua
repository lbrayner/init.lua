local M = {}

function M.on_list(options)
  if #options.items > 1  then
    vim.fn.setqflist({}, " ", options)
    vim.cmd("botright copen")
    return
  end

  local qfitem = options.items[1]
  local filename = qfitem.filename
  local pos = { qfitem.lnum, (qfitem.col - 1) }

  -- From vim.lsp.util.show_document
  -- Push a new item into tagstack
  local from = { vim.fn.bufnr("%"), vim.fn.line("."), vim.fn.col("."), 0 }
  local items = { { tagname = vim.fn.expand("<cword>"), from = from } }
  vim.fn.settagstack(vim.fn.win_getid(), { items = items }, "t")

  require("lbrayner").jump_to_location(filename, pos)
end

return M
