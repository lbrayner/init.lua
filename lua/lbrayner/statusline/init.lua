local M = {}

function M.empty()
  return ""
end

function M.status_flag()
  if vim.bo.modified then
    return "+"
  end
  if vim.bo.modifiable then
    return "-"
  end
  if vim.bo.readonly then
    return "R"
  end
  return " "
end

-- TODO use Neovim API
-- TODO is require("lbrayner.diagnostic").buffer_severity() necessary?
function M.highlight_diagnostics()
  local buffer_severity = require("lbrayner.diagnostic").buffer_severity()
  if not buffer_severity then
    vim.cmd("highlight! User7 ctermfg=NONE guifg=NONE")
    return
  end
  local group = "Diagnostic"..string.sub(buffer_severity, 1, 1)..string.lower(string.sub(buffer_severity, 2))
  local cterm = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID(group)), "fg", "cterm")
  cterm = cterm == "" and "NONE" or cterm
  local gui = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID(group)), "fg", "gui")
  vim.cmd(string.format("highlight! User7 ctermfg=%s guifg=%s", cterm, gui))
end

return M
