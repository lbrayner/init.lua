-- vim: fdm=marker

-- {{{ Helper functions

local FugitiveHead = vim.fn.FugitiveHead
local FugitiveResult = vim.fn.FugitiveResult
local buf_is_scratch = require("lbrayner").buf_is_scratch
local concat = table.concat
local empty_dict = vim.empty_dict
local endswith = vim.endswith
local exists = vim.fn.exists
local fnamemodify = vim.fn.fnamemodify
local fugitiveHead = vim.fn["fugitive#Head"]
local get_diagnostic = vim.diagnostic.get
local get_fugitive_git_dir_ = require("lbrayner.fugitive").get_fugitive_git_dir
local get_fugitive_object = require("lbrayner.fugitive").get_fugitive_object
local get_full_path = require("lbrayner.path").get_full_path
local get_jdtls_buffer_name = require("lbrayner.jdtls").get_buffer_name
local get_line = vim.fn.line
local get_path = require("lbrayner.path").get_path
local get_state = vim.fn.state
local hlID = vim.fn.hlID
local is_fugitive_blame = require("lbrayner.fugitive").is_fugitive_blame
local is_quickfix_or_location_list = require("lbrayner").is_quickfix_or_location_list
local nvim__redraw = vim.api.nvim__redraw
local nvim_buf_get_name = vim.api.nvim_buf_get_name
local nvim_create_augroup = vim.api.nvim_create_augroup
local nvim_create_autocmd = vim.api.nvim_create_autocmd
local nvim_del_autocmd = vim.api.nvim_del_autocmd
local nvim_exec_autocmds = vim.api.nvim_exec_autocmds
local nvim_get_current_buf = vim.api.nvim_get_current_buf
local nvim_get_current_win = vim.api.nvim_get_current_win
local nvim_get_hl = vim.api.nvim_get_hl
local nvim_set_hl = vim.api.nvim_set_hl
local nvim_win_call = vim.api.nvim_win_call
local nvim_win_is_valid = vim.api.nvim_win_is_valid
local pathshorten = vim.fn.pathshorten
local schedule = vim.schedule
local severities = vim.diagnostic.severity
local startswith = vim.startswith
local string_len = string.len
local string_lower = string.lower
local string_sub = string.sub
local synIDattr = vim.fn.synIDattr
local synIDtrans = vim.fn.synIDtrans
local tbl_contains = vim.tbl_contains
local tbl_deep_extend = vim.tbl_deep_extend
local tbl_get = vim.tbl_get
local tbl_isempty = vim.tbl_isempty
local tbl_keys = vim.tbl_keys
local win_is_actual_curwin = require("lbrayner").win_is_actual_curwin
local win_is_floating = require("lbrayner").win_is_floating

local function get_fugitive_git_dir()
  local fugitive_dir = get_fugitive_git_dir_()

  if fugitive_dir then
    return fnamemodify(fugitive_dir, ":~")
  end
end

local function get_fugitive_temporary_buffer_name()
  return concat({ "Git", concat(FugitiveResult(nvim_get_current_buf()).args, " ")}, " ")
end

local function join(t) -- maximum effieciency
  return concat(t, "")
end

local function get_line_format()
  if vim.bo.buftype == "terminal" then
    return join({ "%", (#tostring(vim.bo.scrollback)+1), "l" })
  end

  local length = #tostring(get_line("$"))

  if length < 5 then
    length = 5
  end

  return join({ "%", length, "l" })
end

local function get_number_of_lines()
  if vim.bo.buftype == "terminal" then
    return join({ "%", (#tostring(vim.bo.scrollback)+1), "L" })
  end

  local length = #tostring(get_line("$"))

  if length < 5 then
    length = 5
  end

  return join({ "%-", length, "L" })
end

-- }}}

local function get_buffer_position() -- {{{
  return join({ get_line_format(), ",%-3.v %3.P ", get_number_of_lines() })
end -- }}}

local M = {}

function M.get_buffer_name(opts)
  opts = opts or {}
  local path

  if get_fugitive_object() then
    path = get_fugitive_object()
  elseif startswith(nvim_buf_get_name(0), "jdt://") then -- jdtls
    path = get_jdtls_buffer_name(0)
  else
    path = get_path()
  end

  local buffer_name = path

  if opts.tail then -- default is relative
    buffer_name = fnamemodify(path, ":t")
  end

  if buffer_name == "" then
    return join({ "#", nvim_get_current_buf() })
  end

  return buffer_name
end

function M.get_buffer_status()
  local status = vim.bo.modified and "%1*" or ""

  if vim.wo.previewwindow then
    status = join({ status, "%<", pathshorten(get_full_path()) })
  elseif buf_is_scratch() and nvim_buf_get_name(0) == "" then
    status = join({ status, "%<%5*%f%*" })
  elseif vim.bo.buftype ~= "" then
    status = join({ status, "%<%5*", M.get_buffer_name({ tail = true }), "%*" })
  else
    status = join({ status, "%<", M.get_buffer_name({ tail = true }) })
  end

  status = join({ status, (vim.bo.modified and " " or " %1*"), M.get_status_flag(), "%*" })

  return status
end

function M.get_diagnostics()
  local bufnr = nvim_get_current_buf()

  if tbl_isempty(get_diagnostic(bufnr)) then
    return " "
  end

  return "%7*•%*"
end

function M.get_empty()
  return ""
end

function M.get_minor_modes()
  local bufnr = nvim_get_current_buf()
  local modes = tbl_get(vim.b[bufnr], "lbrayner", "statusline", "modes", "str")

  if modes and modes ~= "" then
    return join({ "%9*", modes, "%* " })
  end

  return ""
end

-- A Nerd Font is required
function M.get_status_flag()
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

-- margins of 1 column (on both sides)
function M.get_statusline()
  if is_fugitive_blame() then
    return join({
      " Fugitive blame ",
      "%<%1*%{v:lua.require'lbrayner.statusline'.get_status_flag()}%*%=",
      get_buffer_position()
    })
  end

  local leftline = " "
  if vim.wo.previewwindow then
    leftline = join({ leftline, "%5*%w%* " })
  end

  if vim.b.fugitive_type and vim.b.fugitive_type == "index" then -- Fugitive summary
    local dir = pathshorten(get_fugitive_git_dir())
    leftline = join({
      leftline, "%6*", dir, "$%* %<", "Fugitive summary ",
      "%1*%{v:lua.require'lbrayner.statusline'.get_status_flag()}%*"
    })
  elseif exists("*FugitiveResult") == 1 and
    not tbl_isempty(FugitiveResult(nvim_get_current_buf())) then -- Fugitive temporary buffers
    local fugitive_temp_buf = get_fugitive_temporary_buffer_name()
    local dir = pathshorten(get_fugitive_git_dir())
    leftline = join({
      leftline, "%6*", dir, "$%* %<", fugitive_temp_buf,
      " %1*%{v:lua.require'lbrayner.statusline'.get_status_flag()}%*"
    })
  elseif is_quickfix_or_location_list() then
    leftline = join({
      leftline,
      "%<%5*%f%* %{v:lua.require'lbrayner'.get_quickfix_or_location_list_title()}"
    })
  elseif vim.w.cmdline then
    leftline = join({ leftline, "%<%5*[Command Line]%*" })
  else
    leftline = join({
      leftline, "%{%v:lua.require'lbrayner.statusline'.get_buffer_status()%}"
    })
  end

  local rightline = join({
    "%{%v:lua.require'lbrayner.statusline'.get_minor_modes()%}",
    get_buffer_position()
  })

  if vim.bo.buftype ~= "" then
    rightline = join({
      rightline,
      "%( %6*%{v:lua.require'lbrayner.statusline'.get_version_control()}%*%) %2*%{&filetype}%* "
    })
  else
    rightline = join({
      rightline,
      " %{%v:lua.require'lbrayner.statusline'.get_diagnostics()%}",
      "%( %6*%{v:lua.require'lbrayner.statusline'.get_version_control()}%*%)",
      " %4*%{v:lua.require'lbrayner'.options(&fileencoding, &encoding, '')}%*",
      " %4.(%4*%{&fileformat}%*%)",
      " %2*%{&filetype}%* "
    })
  end

  return join({ leftline, " %=", rightline })
end

function M.get_version_control()
  if exists("*FugitiveHead") == 0 then
    return ""
  end

  local branch = FugitiveHead()

  if branch == "" then
    branch = fugitiveHead(7)
  end

  if branch == "" then
    return ""
  end

  if string_len(branch) > 60 then
    return join({ string_sub(branch, 1, 54), "…", string_sub(branch, -5) })
  end

  return branch
end

function M.get_winbar()
  if is_fugitive_blame() then
    return " Fugitive blame %<%{v:lua.require'lbrayner.statusline'.get_status_flag()}"
  end

  local statusline = " "
  if vim.wo.previewwindow then
    statusline = join({ statusline, "%w " })
  end

  if vim.b.fugitive_type and vim.b.fugitive_type == "index" then -- Fugitive summary
    local dir = pathshorten(get_fugitive_git_dir())
    statusline = join({
      statusline, dir, "$ %<", "Fugitive summary ",
      "%{v:lua.require'lbrayner.statusline'.get_status_flag()}"
    })
  elseif exists("*FugitiveResult") == 1 and
    not tbl_isempty(FugitiveResult(nvim_get_current_buf())) then -- Fugitive temporary buffers
    local fugitive_temp_buf = get_fugitive_temporary_buffer_name()
    local dir = pathshorten(get_fugitive_git_dir())
    statusline = join({
      statusline, dir, "$ %<", fugitive_temp_buf,
      " %{v:lua.require'lbrayner.statusline'.get_status_flag()}"
    })
  elseif is_quickfix_or_location_list() then
    statusline = join({
      statusline, "%<%f %{v:lua.require'lbrayner'.get_quickfix_or_location_list_title()}"
    })
  elseif vim.w.cmdline then
    statusline = ""
  else
    if vim.wo.previewwindow then
      statusline = join({
        statusline, "%<", pathshorten(get_full_path())
      })
    else
      -- margins of 1 column, space and status flag
      statusline = join({
        statusline,
        "%<%{v:lua.require'lbrayner'.truncate_filename(",
        "v:lua.require'lbrayner.statusline'.get_buffer_name(), winwidth('%') - 4)}"
      })
    end
    statusline = join({ statusline, " %{v:lua.require'lbrayner.statusline'.get_status_flag()}" })
  end

  return statusline
end

local mapping

function M.highlight_mode(mode)
  local hl_map_by_group = mapping[mode]
  for group, hl_map in pairs(hl_map_by_group) do
    current_hl_map = nvim_get_hl(0, { name = group })
    hl_map = tbl_deep_extend("keep", { bold = true }, hl_map, {
      bg = current_hl_map.bg,
      fg = current_hl_map.fg
    })
    nvim_set_hl(0, group, hl_map)
  end
end

function M.highlight_winbar()
  local normal = nvim_get_hl(0, { name = "Normal" })
  nvim_set_hl(0, "WinBar", { bold = true, fg = normal.fg })
  nvim_set_hl(0, "WinBarNC", { bold = true, fg = normal.fg })
end

function M.load_theme(name)
  local success, theme = pcall(require, join({ "lbrayner.statusline.themes.", name }))
  if not success then
    theme = require("lbrayner.statusline.themes.neosolarized")
  end
  mapping = theme.get_color_mapping()
  for mode, hl_map_by_group in pairs(mapping) do
    for group, hl_map in pairs(hl_map_by_group) do
      local guibg = synIDattr(synIDtrans(hlID(hl_map.bg)), "fg", "gui")
      local guifg = synIDattr(synIDtrans(hlID(hl_map.fg)), "fg", "gui")
      mapping[mode][group] = { bg = (hl_map.bg and guibg), fg = (hl_map.fg and guifg) }
    end
  end
  M.highlight_mode("normal")
  M.highlight_winbar()
end

function M.set_minor_modes(bufnr, mode, action)
  assert(type(bufnr) == "number" and bufnr > 0, "'bufnr' must be a positive number")
  assert(type(mode) == "string", "'mode' must be a string")
  assert(action == "append" or action == "remove", join({ "invalid 'action': ", tostring(action) }))

  local lbrayner = vim.b[bufnr].lbrayner or empty_dict()
  local data = tbl_get(lbrayner, "statusline", "modes", "data") or empty_dict()

  if action == "append" then
    data[mode] = true
  elseif action == "remove" then
    data[mode] = nil
  end

  local keys = tbl_keys(data)
  table.sort(keys)

  lbrayner = tbl_deep_extend("keep", {
    statusline = {
      modes = {
        str = table.concat(keys, ",")
      }
    }
  }, lbrayner)

  lbrayner.statusline.modes.data = data
  vim.b[bufnr].lbrayner = lbrayner
end

-- Options

vim.go.laststatus = 3
vim.go.statusline = "%{v:lua.require'lbrayner.statusline'.get_empty()}"
vim.go.winbar = "%{%v:lua.require'lbrayner.statusline'.get_winbar()%}"

-- Variables

-- From :h qf.vim:

-- The quickfix filetype plugin includes configuration for displaying the command
-- that produced the quickfix list in the status-line. To disable this setting,
-- configure as follows:

vim.g.qf_disable_statusline = 1

-- Autocmds

local function define_status_line() -- {{{
  if win_is_actual_curwin() then
    vim.wo.statusline = M.get_statusline()
  end
end -- }}}

local statusline = nvim_create_augroup("statusline", { clear = true })

nvim_create_autocmd("CmdlineEnter", {
  pattern = { ":", "/", "?" },
  group = statusline,
  desc = "Command-line modes statusline highlight",
  callback = function(args)
    local cmdline_char = args.file

    -- cmdline-char "@": do not redraw if waiting for input after input()
    -- state() "s": screen has scrolled for messages (multi-line input prompt)
    -- See https://github.com/neovim/neovim/issues/34662
    if cmdline_char == "@" and endswith(get_state(), "s") then
      return
    end

    if tbl_contains({ "/", "?" }, cmdline_char) then
      M.highlight_mode("search")
    else
      M.highlight_mode("command")
    end

    nvim__redraw({ statusline = true })
  end,
})

nvim_create_autocmd("ColorScheme", {
  group = statusline,
  desc = "Load statusline theme",
  callback = function(args)
    local colorscheme = args.match
    M.load_theme(colorscheme)
  end,
})

nvim_create_autocmd("ModeChanged", {
  pattern = [[[^i]*:i*]],
  group = statusline,
  desc = "Insert mode statusline highlight",
  callback = function()
    M.highlight_mode("insert")
  end,
})

nvim_create_autocmd("ModeChanged", {
  pattern = [[[^vV\x16]:[vV\x16]*]],
  group = statusline,
  desc = "Visual modes statusline highlight",
  callback = function()
    M.highlight_mode("visual")
  end,
})

nvim_create_autocmd("ModeChanged", {
  pattern = "[^n]*:n*",
  group = statusline,
  desc = "Command/Normal mode statusline highlight",
  callback = function()
    M.highlight_mode("normal")
  end,
})

nvim_create_autocmd("TermEnter", {
  group = statusline,
  desc = "Terminal mode statusline definition and highlight",
  callback = function()
    M.highlight_mode("terminal")
    local winid = nvim_get_current_win()
    schedule(function()
      if nvim_win_is_valid(winid) then
        nvim_win_call(winid, function()
          vim.wo.statusline = ""
        end)
      end
    end)
  end,
})

nvim_create_autocmd("TermLeave", {
  group = statusline,
  desc = "Restore regular statusline",
  callback = define_status_line,
})

nvim_create_autocmd("VimEnter", {
  group = statusline,
  desc = "Create statusline autocmds",
  callback = function()
    local diagnostic_changed_autocmd

    local function diagnostic_changed(bufnr)
      local function highlight_severity(bufnr)
        local severity = (function(bufnr)
          if tbl_isempty(get_diagnostic(bufnr)) then
            return nil
          end
          for _, level in ipairs(severities) do
            local items =  get_diagnostic(bufnr, { severity = level })
            if not tbl_isempty(items) then
              return level
            end
          end
        end)(bufnr)

        local user7 = nvim_get_hl(0, { name = "User7" })

        if not severity then
          nvim_set_hl(0, "User7", tbl_deep_extend("keep", { fg = "NONE" }, user7))
          return
        end

        local group = join({
          "Diagnostic", string_sub(severity, 1, 1), string_lower(string_sub(severity, 2))
        })
        local severity_hl = nvim_get_hl(0, { name = group })
        nvim_set_hl(0, "User7", tbl_deep_extend("keep", { fg = severity_hl.fg }, user7))
      end

      highlight_severity(bufnr)

      pcall(nvim_del_autocmd, diagnostic_changed_autocmd)

      diagnostic_changed_autocmd = nvim_create_autocmd("DiagnosticChanged", {
        group = statusline,
        buffer = bufnr,
        desc = "Diagnostic severity statusline highlight",
        callback = function(args)
          local bufnr = args.buf
          highlight_severity(bufnr)
        end,
      })
    end

    nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
      group = statusline,
      desc = "Define window local statusline, buffer-local diagnostic autocmd",
      callback = function(args)
        if win_is_floating() then
          -- Statusline is not allowed in floating windows (see :h
          -- api-floatwin). Moreover BufWinEnter and WinEnter are triggered
          -- even when {enter} is false (see :h nvim_open_win).
          return
        end

        local bufnr = args.buf

        diagnostic_changed(bufnr)

        if vim.go.statusline == vim.wo.statusline then
          schedule(define_status_line)
        end
      end,
    })

    -- Useful when reloading the module
    if not mapping and
      vim.g.colors_name and
      vim.g.colors_name ~= "" then
      M.load_theme(vim.g.colors_name)
    end

    -- Useful when reloading the module
    if not mapping and not vim.g.colors_name then
      -- A statusline theme is required
      M.load_theme("neosolarized")
    end

    schedule(define_status_line)
    schedule(function()
      diagnostic_changed(nvim_get_current_buf())
    end)
  end,
})

-- rocks.nvim wasn't synced at least once
-- Defining this early to avoid flickering
if not pcall(require, "neosolarized") then
  -- A statusline theme is required
  M.load_theme("neosolarized")
end

if vim.v.vim_did_enter == 1 then
  nvim_exec_autocmds("VimEnter", { group = statusline })
end

return M
