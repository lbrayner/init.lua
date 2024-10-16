local M = {}

-- From :h qf.vim:

-- The quickfix filetype plugin includes configuration for displaying the command
-- that produced the quickfix list in the status-line. To disable this setting,
-- configure as follows:

vim.g.qf_disable_statusline = 1

vim.go.laststatus = 3
vim.go.statusline = "%{v:lua.require'lbrayner.statusline'.empty()}"
vim.go.winbar = "%{%v:lua.require'lbrayner.statusline'.winbar()%}"

function M.empty()
  return ""
end

-- A Nerd Font is required
function M.status_flag()
  if vim.bo.modified then
    if vim.bo.readonly then
      return "󰷢"
    end
    return "󱦹"
  end
  if vim.bo.buftype == "help" then
    return ""
  end
  if vim.bo.buftype == "terminal" then
    return ""
  end
  if not vim.bo.modifiable then
    return "󰷤"
  end
  if vim.bo.readonly then
    return "󰌾"
  end
  return " "
end

local function get_buffer_severity(bufnr)
  if vim.tbl_isempty(vim.diagnostic.get(bufnr)) then
    return nil
  end
  for _, level in ipairs(vim.diagnostic.severity) do
    local items =  vim.diagnostic.get(bufnr, { severity = level })
    if not vim.tbl_isempty(items) then
      return level
    end
  end
end

function M.highlight_diagnostics(opts)
  opts = opts or {}

  if vim.api.nvim_get_current_buf() ~= opts.buf then
    return
  end

  local buffer_severity = opts.buffer_severity

  if not buffer_severity then
    buffer_severity = get_buffer_severity(opts.buf)
  end

  if not buffer_severity then
    vim.cmd("highlight! User7 guifg=NONE") -- Using ex highlight because nvim_set_hl can't update
    return
  end

  local group = "Diagnostic"..string.sub(buffer_severity, 1, 1)..string.lower(string.sub(buffer_severity, 2))
  local guifg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID(group)), "fg", "gui")
  vim.cmd(string.format("highlight! User7 guifg=%s", guifg)) -- nvim_set_hl can't update
end

function M.diagnostics()
  local bufnr = vim.api.nvim_get_current_buf()
  local buffer_severity = get_buffer_severity(bufnr)
  if not buffer_severity then
    return " "
  end
  M.highlight_diagnostics({ buf = bufnr, buffer_severity = buffer_severity })
  return "%7*•%*"
end

function M.version_control()
  if vim.fn.exists("*FugitiveHead") == 0 then
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

local function get_buffer_position()
  return get_line_format()..",%-3.v %3.P "..get_number_of_lines()
end

function M.get_status_line_tail()
  local buffer_position = get_buffer_position()
  if vim.bo.buftype ~= "" then
    return buffer_position ..
    "%( %6*%{v:lua.require'lbrayner.statusline'.version_control()}%*%) %2*%{&filetype}%* "
  end
  return buffer_position ..
  " %1.1{%v:lua.require'lbrayner.statusline'.diagnostics()%}" ..
  "%( %6*%{v:lua.require'lbrayner.statusline'.version_control()}%*%)" ..
  " %4*%{v:lua.require'lbrayner'.options(&fileencoding, &encoding, '')}%*" ..
  " %4.(%4*%{&fileformat}%*%)" ..
  " %2*%{&filetype}%* "
end

function M.get_buffer_name(relative)
  local path = require("lbrayner.path").path()

  if require("lbrayner.fugitive").fugitive_object() then
    path = require("lbrayner.fugitive").fugitive_object()
  elseif vim.startswith(vim.api.nvim_buf_get_name(0), "jdt://") then -- jdtls
    path = string.gsub(vim.api.nvim_buf_get_name(0), "%?.*", "")
  end

  local buffer_name = path

  if not relative then
    buffer_name = vim.fn.fnamemodify(path, ":t")
  end

  if buffer_name == "" then
    return "#"..vim.api.nvim_get_current_buf()
  end

  return buffer_name
end

local function fugitive_temporary_buffer()
  return "Git "..table.concat(vim.fn.FugitiveResult(vim.api.nvim_get_current_buf()).args, " ")
end

-- margins of 1 column (on both sides)
function M.define_modified_status_line()
  local leftline = " "

  if vim.wo.previewwindow then
    leftline = leftline.."%5*%w%* "
  end

  if vim.b.Statusline_custom_mod_leftline then
    leftline = leftline..vim.b.Statusline_custom_mod_leftline
  else
    leftline = leftline.."%1*"
    if vim.wo.previewwindow then
      leftline = leftline.."%<"..vim.fn.pathshorten(require("lbrayner.path").full_path())
    else
      leftline = leftline.."%<"..M.get_buffer_name()
    end
    leftline = leftline.." %{v:lua.require'lbrayner.statusline'.status_flag()}%*"
  end

  local rightline = ""
  if vim.b.Statusline_custom_mod_rightline then
    rightline = rightline..vim.b.Statusline_custom_mod_rightline
  end
  rightline = rightline..M.get_status_line_tail()

  vim.wo.statusline = leftline.." %="..rightline
end

function M.winbar()
  if vim.fn.exists("*FugitiveResult") == 1 then
    local fugitive_result = vim.fn.FugitiveResult(vim.api.nvim_get_current_buf())
    if fugitive_result.filetype and
      fugitive_result.blame_file and
      fugitive_result.filetype == "fugitiveblame" then -- Fugitive blame
      return " Fugitive blame %<%{v:lua.require'lbrayner.statusline'.status_flag()}"
    end
  end

  local statusline = " "
  if vim.wo.previewwindow then
    statusline = statusline.."%w "
  end

  if vim.b.fugitive_type and vim.b.fugitive_type == "index" then -- Fugitive summary
    local dir = vim.fn.pathshorten(require("lbrayner.fugitive").fugitive_git_dir())
    statusline = statusline..dir.."$ %<".."Fugitive summary " ..
    "%{v:lua.require'lbrayner.statusline'.status_flag()}"
  elseif vim.fn.exists("*FugitiveResult") == 1 and
    not vim.tbl_isempty(vim.fn.FugitiveResult(vim.api.nvim_get_current_buf())) then -- Fugitive temporary buffers
    local fugitive_temp_buf = fugitive_temporary_buffer()
    local dir = vim.fn.pathshorten(require("lbrayner.fugitive").fugitive_git_dir())
    statusline = statusline..dir.."$ %<"..fugitive_temp_buf ..
    " %{v:lua.require'lbrayner.statusline'.status_flag()}"
  elseif require("lbrayner").is_quickfix_or_location_list() then
    statusline = statusline.."%<%f %{v:lua.require'lbrayner'.get_quickfix_or_location_list_title()}"
  elseif vim.w.cmdline then
    statusline = ""
  else
    if vim.wo.previewwindow then
      statusline = statusline.."%<"..vim.fn.pathshorten(require("lbrayner.path").full_path())
    else
      -- margins of 1 column, space and status flag
      statusline = statusline ..
      "%<%{v:lua.require'lbrayner'.truncate_filename(" ..
      "v:lua.require'lbrayner.statusline'.get_buffer_name(v:true),winwidth('%')-4)}"
    end
    statusline = statusline.." %{v:lua.require'lbrayner.statusline'.status_flag()}"
  end

  return statusline
end

function M.define_terminal_status_line()
  vim.wo.statusline = ""
end

-- margins of 1 column (on both sides)
function M.define_status_line()
  if vim.fn.exists("*FugitiveResult") == 1 then
    local fugitive_result = vim.fn.FugitiveResult(vim.api.nvim_get_current_buf())
    if fugitive_result.filetype and
      fugitive_result.blame_file and
      fugitive_result.filetype == "fugitiveblame" then -- Fugitive blame
      vim.wo.statusline =
      " Fugitive blame %<%1*%{v:lua.require'lbrayner.statusline'.status_flag()}%*%="..get_buffer_position()
      return
    end
  end

  local leftline = " "
  if vim.wo.previewwindow then
    leftline = leftline.."%5*%w%* "
  end

  if vim.b.fugitive_type and vim.b.fugitive_type == "index" then -- Fugitive summary
    local dir = vim.fn.pathshorten(require("lbrayner.fugitive").fugitive_git_dir())
    leftline = leftline.."%6*"..dir.."$%* %<".."Fugitive summary " ..
    "%1*%{v:lua.require'lbrayner.statusline'.status_flag()}%*"
  elseif vim.fn.exists("*FugitiveResult") == 1 and
    not vim.tbl_isempty(vim.fn.FugitiveResult(vim.api.nvim_get_current_buf())) then -- Fugitive temporary buffers
    local fugitive_temp_buf = fugitive_temporary_buffer()
    local dir = vim.fn.pathshorten(require("lbrayner.fugitive").fugitive_git_dir())
    leftline = leftline.."%6*"..dir.."$%* %<"..fugitive_temp_buf ..
    " %1*%{v:lua.require'lbrayner.statusline'.status_flag()}%*"
  elseif require("lbrayner").is_quickfix_or_location_list() then
    leftline = leftline ..
    "%<%5*%f%* %{v:lua.require'lbrayner'.get_quickfix_or_location_list_title()}"
  elseif vim.w.cmdline then
    leftline = leftline.."%<%5*[Command Line]%*"
  elseif vim.b.Statusline_custom_leftline then
    leftline = leftline..vim.b.Statusline_custom_leftline
  else
    if vim.wo.previewwindow then
      leftline = leftline.."%<"..vim.fn.pathshorten(require("lbrayner.path").full_path())
    elseif require("lbrayner").buffer_is_scratch() and
      vim.api.nvim_buf_get_name(0) == "" then
      leftline = leftline.."%<%5*%f%*"
    elseif vim.bo.buftype ~= "" then
      leftline = leftline.."%<%5*"..M.get_buffer_name().."%*"
    else
      leftline = leftline.."%<"..M.get_buffer_name().."%*"
    end
    leftline = leftline.." %1*%{v:lua.require'lbrayner.statusline'.status_flag()}%*"
  end

  local rightline = ""
  if vim.b.Statusline_custom_mod_rightline then
    rightline = rightline..vim.b.Statusline_custom_mod_rightline
  end
  rightline = rightline..M.get_status_line_tail()

  vim.wo.statusline = leftline.." %="..rightline
end

function M.redefine_status_line()
  if vim.startswith(vim.fn.mode(), "t") then
    return
  end
  -- This variable is defined by the runtime.
  -- :h g:actual_curwin
  if vim.g.actual_curwin and vim.g.actual_curwin ~= vim.api.nvim_get_current_win() then
    return
  end
  if vim.bo.modified then
    M.define_modified_status_line()
  else
    M.define_status_line()
  end
end

local mapping

function M.highlight_mode(mode)
  local hl_map_by_group = mapping[mode]
  for group, hl_map in pairs(hl_map_by_group) do
    current_hl_map = vim.api.nvim_get_hl(0, { name = group })
    hl_map = vim.tbl_deep_extend("keep", { bold = true }, hl_map, {
      bg = current_hl_map.bg,
      fg = current_hl_map.fg
    })
    vim.api.nvim_set_hl(0, group, hl_map)
  end
end

function M.highlight_winbar()
  local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
  vim.api.nvim_set_hl(0, "WinBar", { bold = true, fg = normal.fg })
  vim.api.nvim_set_hl(0, "WinBarNC", { bold = true, fg = normal.fg })
end

function M.load_theme(name)
  local success, theme = pcall(require, "lbrayner.statusline.themes."..name)
  if not success then
    theme = require("lbrayner.statusline.themes.neosolarized")
  end
  mapping = theme.get_color_mapping()
  for mode, hl_map_by_group in pairs(mapping) do
    for group, hl_map in pairs(hl_map_by_group) do
      local guibg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID(hl_map.bg)), "fg", "gui")
      local guifg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID(hl_map.fg)), "fg", "gui")
      mapping[mode][group] = { bg = (hl_map.bg and guibg), fg = (hl_map.fg and guifg) }
    end
  end
  M.highlight_mode("normal")
  M.highlight_winbar()
end

-- Autocmds

local statusline = vim.api.nvim_create_augroup("statusline", { clear = true })

vim.api.nvim_create_autocmd("CmdlineEnter", {
  pattern = { ":", "/", "?" },
  group = statusline,
  callback = function(args)
    if args.file == ":" then
      M.highlight_mode("command")
    elseif vim.tbl_contains({ "/", "?" }, args.file) then
      M.highlight_mode("search")
    else
      return
    end
    vim.cmd.redraw() -- TODO redrawstatus should work here, create an issue on github
  end,
})

vim.api.nvim_create_autocmd("ColorScheme", {
  group = statusline,
  callback = function(args)
    local colorscheme = args.match
    M.load_theme(colorscheme)
  end,
})

vim.api.nvim_create_autocmd("DiagnosticChanged", {
  group = statusline,
  callback = M.highlight_diagnostics,
})

vim.api.nvim_create_autocmd("InsertEnter", {
  group = statusline,
  callback = function()
    M.highlight_mode("insert")
    M.redefine_status_line()
  end,
})

vim.api.nvim_create_autocmd("ModeChanged", {
  pattern = [[[^vV\x16]:[vV\x16]*]],
  group = statusline,
  callback = function()
    M.highlight_mode("visual")
  end,
})

vim.api.nvim_create_autocmd("ModeChanged", {
  pattern = "[^n]*:n*",
  group = statusline,
  callback = function()
    M.highlight_mode("normal")
  end,
})

vim.api.nvim_create_autocmd("TermEnter", {
  group = statusline,
  callback = function()
    M.highlight_mode("terminal")
    M.define_terminal_status_line()
  end,
})

vim.api.nvim_create_autocmd("TermLeave", {
  group = statusline,
  callback = M.redefine_status_line,
})

vim.api.nvim_create_autocmd("User", {
  pattern = "CustomStatusline",
  group = statusline,
  callback = M.redefine_status_line,
})

vim.api.nvim_create_autocmd("VimEnter", {
  group = statusline,
  callback = function()
    vim.api.nvim_create_autocmd({ "BufWinEnter", "BufWritePost", "TextChanged", "TextChangedI", "WinEnter" }, {
      group = statusline,
      callback = vim.schedule_wrap(M.redefine_status_line),
    })
    vim.schedule(M.redefine_status_line)
  end,
})

if vim.v.vim_did_enter == 1 then
  vim.api.nvim_exec_autocmds("VimEnter", { group = statusline })
end

return M
