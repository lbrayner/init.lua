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

local function get_line_format()
  if vim.bo.buftype == "terminal" then
    return "%"..(#tostring(vim.bo.scrollback)+1).."l"
  end
  local length = #tostring(vim.fn.line("$"))
  if length < 5 then
    length = 5
  end
  return "%"..length.."l"
end

local function get_number_of_lines()
  if vim.bo.buftype == "terminal" then
    return "%"..(#tostring(vim.bo.scrollback)+1).."L"
  end
  local length = #tostring(vim.fn.line("$"))
  if length < 5 then
    length = 5
  end
  return "%-"..length.."L"
end

local function buffer_position()
  return get_line_format()..",%-3.v %3.P "..get_number_of_lines()
end

function M.get_status_line_tail()
  local buffer_position = buffer_position()
  if vim.bo.buftype ~= "" then
    return buffer_position .. "%( %6*%{v:lua.require'lbrayner.statusline'.version_control()}%*%) %2*%{&filetype}%* "
  end
  return buffer_position ..
  " %1.1{%v:lua.require'lbrayner.statusline'.diagnostics()%}" ..
  "%( %6*%{v:lua.require'lbrayner.statusline'.version_control()}%*%)" ..
  " %4*%{util#Options('&fileencoding','&encoding')}%*" .. -- TODO util#Options is buggy, port it and fix it
  " %4.(%4*%{&fileformat}%*%)" ..
  " %2*%{&filetype}%* "
end

function M.filename(full_path)
  local path = vim.fn.Path()

  if vim.fn.exists("*FugitiveParse") and vim.fn.FObject() ~= "" then -- Fugitive objects
    path = vim.fn.FObject()
  elseif string.find(vim.api.nvim_buf_get_name(0), "jdt://", 1) == 1 then -- jdtls
    path = string.gsub(vim.api.nvim_buf_get_name(0), "%?.*", "")
  end

  local filename
  if full_path then -- Full path
    filename = string.gsub(path, "'", "''")
  else
    filename = string.gsub(vim.fn.fnamemodify(path, ":t"), "'", "''")
  end

  if filename == "" then
    return "#"..vim.api.nvim_get_current_buf()
  end

  return filename
end

return M
