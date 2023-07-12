local M = {}

function M.get_session()
  -- vim-obsession
  local session = string.gsub(vim.v.this_session, "%.%d+%.obsession~?", "")
  if session ~= "" then
    return vim.fn.fnamemodify(session, ":t:r")
  end
end

return M
