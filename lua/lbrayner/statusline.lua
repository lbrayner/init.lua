local M = {}

function M.empty()
  return ""
end

function M.status_flag()
  if vim.bo.modified then
    return "+"
  end
  if not vim.bo.modifiable then
    return "-"
  end
  if vim.bo.readonly then
    return "R"
  end
  return " "
end

local function buffer_severity()
  if not (vim.tbl_count(vim.diagnostic.get(0)) > 0) then
    return nil
  end
  for _, level in ipairs(vim.diagnostic.severity) do
    local items =  vim.diagnostic.get(0, { severity = level })
    if vim.tbl_count(items) > 0 then
      return level
    end
  end
end

function M.highlight_diagnostics(buffer_severity)
  if not buffer_severity then
    buffer_severity = buffer_severity()
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
  local buffer_severity = buffer_severity()
  if not buffer_severity then
    return " "
  end
  M.highlight_diagnostics(buffer_severity)
  return "%7*•%*"
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

local function fugitive_temporary_buffer()
  return "Git "..table.concat(vim.fn.FugitiveResult(vim.api.nvim_get_current_buf()).args, " ")
end

-- margins of 1 column (on both sides)
function M.define_modified_status_line()
  local rightline = ""
  if vim.b.Statusline_custom_mod_rightline then
    rightline = rightline..vim.b.Statusline_custom_mod_rightline
  end
  rightline = rightline..M.get_status_line_tail()

  vim.wo.statusline = " "
  if vim.wo.previewwindow then
    vim.wo.statusline = vim.wo.statusline.."%5*%w%* "
  end

  if vim.b.Statusline_custom_mod_leftline then
    vim.wo.statusline = vim.wo.statusline..vim.b.Statusline_custom_mod_leftline
  else
    if vim.wo.previewwindow then
      vim.wo.statusline = vim.wo.statusline.."%<%1*"..vim.fn.pathshorten(M.filename(true))
    else
      vim.wo.statusline = vim.wo.statusline.."%<%1*"..M.filename()
    end

    vim.wo.statusline = vim.wo.statusline.." %{v:lua.require'lbrayner.statusline'.status_flag()}%*"
  end

  vim.wo.statusline = vim.wo.statusline.." %="..rightline
end

function M.win_bar()
  -- Fugitive blame
  if vim.fn.exists("*FugitiveResult") then
    local fugitive_result = vim.fn.FugitiveResult(vim.api.nvim_get_current_buf())
    if fugitive_result.filetype and
      fugitive_result.blame_file and
      fugitive_result.filetype == "fugitiveblame" then
      return " Fugitive blame %<%{v:lua.require'lbrayner.statusline'.status_flag()}"
    end
  end

  local statusline = " "
  if vim.wo.previewwindow then
    statusline = statusline.."%w "
  end

  -- Fugitive summary
  if vim.b.fugitive_type and vim.b.fugitive_type == "index" then
    -- TODO port util#NPath
    local dir = vim.fn.pathshorten(string.gsub(vim.fn["util#NPath"](vim.fn.FugitiveGitDir()),"/%.git$",""))
    statusline = statusline..dir.."$ %<".."Fugitive summary " ..
    "%{v:lua.require'lbrayner.statusline'.status_flag()}"
    -- Fugitive temporary buffers
  elseif vim.fn.exists("*FugitiveResult") and
    not vim.tbl_isempty(vim.fn.FugitiveResult(vim.api.nvim_get_current_buf())) then
    local fugitive_temp_buf = fugitive_temporary_buffer()
    local dir = vim.fn.pathshorten(string.gsub(vim.fn["util#NPath"](vim.fn.FugitiveGitDir()),"/%.git$",""))
    statusline = statusline..dir.."$ %<"..fugitive_temp_buf ..
    " %{v:lua.require'lbrayner.statusline'.status_flag()}"
    -- TODO port util#isQuickfixOrLocationList
  elseif vim.fn["util#isQuickfixOrLocationList"]() == 1 then
    statusline = statusline.."%<%f %{util#getQuickfixOrLocationListTitle()}"
  elseif vim.fn.getcmdwintype() ~= "" then
    statusline = ""
  else
    if vim.wo.previewwindow then
      statusline = statusline.."%<"..vim.fn.pathshorten(M.filename(true))
    else
      -- margins of 1 column, space and status flag
      -- TODO port util#truncateFilename
      statusline = statusline ..
      "%<%{util#truncateFilename(v:lua.require'lbrayner.statusline'.filename(v:true),winwidth('%')-4)}"
    end

    statusline = statusline.." %{v:lua.require'lbrayner.statusline'.status_flag()}"
  end

  return statusline
end

function M.define_terminal_status_line()
  vim.wo.statusline = "%3*%=%*"
end

-- margins of 1 column (on both sides)
function M.define_status_line()
  -- Fugitive blame
  if vim.fn.exists("*FugitiveResult") then
    local fugitive_result = vim.fn.FugitiveResult(vim.api.nvim_get_current_buf())
    if fugitive_result.filetype and
      fugitive_result.blame_file and
      fugitive_result.filetype == "fugitiveblame" then
      vim.wo.statusline = " Fugitive blame %<%1*%{v:lua.require'lbrayner.statusline'.status_flag()}%*%="
      vim.wo.statusline = vim.wo.statusline..buffer_position()
      return
    end
  end

  local rightline = ""
  if vim.b.Statusline_custom_mod_rightline then
    rightline = rightline..vim.b.Statusline_custom_mod_rightline
  end
  rightline = rightline..M.get_status_line_tail()

  vim.wo.statusline = " "
  if vim.wo.previewwindow then
    vim.wo.statusline = vim.wo.statusline.."%5*%w%* "
  end

  -- Fugitive summary
  if vim.b.fugitive_type and vim.b.fugitive_type == "index" then
    -- TODO port util#NPath
    local dir = vim.fn.pathshorten(string.gsub(vim.fn["util#NPath"](vim.fn.FugitiveGitDir()),"/%.git$",""))
    vim.wo.statusline = vim.wo.statusline.."%6*"..dir.."$%* %<".."Fugitive summary " ..
    "%1*%{v:lua.require'lbrayner.statusline'.status_flag()}%*"
    -- Fugitive temporary buffers
  elseif vim.fn.exists("*FugitiveResult") and
    not vim.tbl_isempty(vim.fn.FugitiveResult(vim.api.nvim_get_current_buf())) then
    local fugitive_temp_buf = fugitive_temporary_buffer()
    local dir = vim.fn.pathshorten(string.gsub(vim.fn["util#NPath"](vim.fn.FugitiveGitDir()),"/%.git$",""))
    vim.wo.statusline = vim.wo.statusline.."%6*"..dir.."$%* %<"..fugitive_temp_buf ..
    " %1*%{v:lua.require'lbrayner.statusline'.status_flag()}%*"
  -- TODO port util#isQuickfixOrLocationList
  elseif vim.fn["util#isQuickfixOrLocationList"]() == 1 then
    vim.wo.statusline = vim.wo.statusline.."%<%5*%f%* %{util#getQuickfixOrLocationListTitle()}"
  elseif vim.fn.getcmdwintype() ~= "" then
    vim.wo.statusline = vim.wo.statusline.."%<%5*[Command Line]%*"
  elseif vim.b.Statusline_custom_leftline then
    vim.wo.statusline = vim.wo.statusline..vim.b.Statusline_custom_leftline
  else
    if vim.wo.previewwindow then
      vim.wo.statusline = vim.wo.statusline.."%<"..vim.fn.pathshorten(M.filename(true))
    elseif vim.bo.buftype ~= "" then
      vim.wo.statusline = vim.wo.statusline.."%<%5*"..M.filename().."%*"
    else
      vim.wo.statusline = vim.wo.statusline.."%<"..M.filename().."%*"
    end

    vim.wo.statusline = vim.wo.statusline.." %1*%{v:lua.require'lbrayner.statusline'.status_flag()}%*"
  end

  vim.wo.statusline = vim.wo.statusline.." %="..rightline
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
    require("lbrayner.statusline").define_modified_status_line()
  else
    require("lbrayner.statusline").define_status_line()
  end
end

local attr
local mapping

function M.highlight_mode(mode)
  local attr_map = attr[mode]
  local hl_map_by_group = {
    StatusLine = { bg = mapping["bg_"..mode], fg = mapping["fg_"..mode] },
    User1 = { bg = mapping["user1_bg_"..mode], fg = mapping["user1_fg_"..mode] },
    User2 = { bg = mapping["user2_bg_"..mode], fg = mapping["user2_fg_"..mode] },
    User3 = { bg = mapping["user3_bg_"..mode], fg = mapping["user3_fg_"..mode] },
    User4 = { bg = mapping["user4_bg_"..mode], fg = mapping["user4_fg_"..mode] },
    User5 = { bg = mapping["user5_bg_"..mode], fg = mapping["user5_fg_"..mode] },
    User6 = { bg = mapping["user6_bg_"..mode], fg = mapping["user6_fg_"..mode] },
    User9 = { bg = mapping["user9_bg_"..mode], fg = mapping["user9_fg_"..mode] }}
  for group, hl_map in pairs(hl_map_by_group) do
    vim.api.nvim_set_hl(0, group, vim.tbl_deep_extend("error", attr_map, hl_map))
  end
  vim.cmd(string.format("highlight! User7 guibg=%s", mapping["diagn_bg_"..mode])) -- nvim_set_hl can't update
end

function M.highlight_status_line_nc()
    vim.api.nvim_set_hl(0, "StatusLineNC", { bg = mapping.not_current_bg, fg = mapping.not_current_fg })
end

function M.load_theme(name)
  local theme = require("lbrayner.statusline.themes."..name)
  attr = theme.get_attr_map()
  mapping = theme.get_color_mapping()
  for key, color_name in pairs(mapping) do
    mapping[key] = require("lbrayner.statusline.themes").get_color(color_name, "gui")
  end
  M.highlight_mode("normal")
  M.highlight_status_line_nc()
end

function M.initialize()
  M.load_theme("default")
end

return M
