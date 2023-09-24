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

-- TODO is require("lbrayner.diagnostic").buffer_severity() necessary?
function M.diagnostics()
  local buffer_severity = require("lbrayner.diagnostic").buffer_severity()
  if not buffer_severity then
    return " "
  end
  M.highlight_diagnostics()
  local prefix = require("lbrayner.diagnostic").get_prefix()
  return "%7*"..prefix.."%*"
end

function M.version_control()
  if not vim.fn.exists("*FugitiveHead") then
    return ""
  end
  local branch = vim.fn.FugitiveHead()
  if branch == "" then
    branch = vim.fn["fugitive#Head"](7)
  end
  if branch == "" then
    return ""
  end
  if string.len(branch) > 30 then
    return string.sub(branch, 1, 24).."…"..string.sub(branch, -5)
  end
  return branch
end

return M
