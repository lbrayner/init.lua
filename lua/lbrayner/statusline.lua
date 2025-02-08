-- vim: fdm=marker

-- {{{ Helper functions

local function get_fugitive_temporary_buffer_name()
  return "Git " .. table.concat(vim.fn.FugitiveResult(vim.api.nvim_get_current_buf()).args, " ")
end

local function get_number_of_lines()
  if vim.bo.buftype == "terminal" then
    return "%" .. (#tostring(vim.bo.scrollback)+1) .. "L"
  end

  local length = #tostring(vim.fn.line("$"))

  if length < 5 then
    length = 5
  end

  return "%-" .. length .. "L"
end

local function get_line_format()
  if vim.bo.buftype == "terminal" then
    return "%" .. (#tostring(vim.bo.scrollback)+1) .. "l"
  end

  local length = #tostring(vim.fn.line("$"))

  if length < 5 then
    length = 5
  end

  return "%" .. length .. "l"
end

local function get_buffer_position()
  return get_line_format() .. ",%-3.v %3.P " .. get_number_of_lines()
end

-- }}}

local M = {}

function M.get_buffer_name(opts)
  opts = opts or {}
  local path = require("lbrayner.path").path()

  if require("lbrayner.fugitive").get_fugitive_object() then
    path = require("lbrayner.fugitive").get_fugitive_object()
  elseif vim.startswith(vim.api.nvim_buf_get_name(0), "jdt://") then -- jdtls
    path = string.gsub(vim.api.nvim_buf_get_name(0), "%?.*", "")
  end

  local buffer_name = path

  if opts.tail then -- default is relative
    buffer_name = vim.fn.fnamemodify(path, ":t")
  end

  if buffer_name == "" then
    return "#" .. vim.api.nvim_get_current_buf()
  end

  return buffer_name
end

function M.get_minor_modes()
  local bufnr = vim.api.nvim_get_current_buf()
  local modes = vim.tbl_get(vim.b[bufnr], "lbrayner", "statusline", "modes", "str")

  if modes and modes ~= "" then
    return "%9*" .. modes .. "%* "
  end

  return ""
end

function M.get_buffer_status()
  local status = vim.bo.modified and "%1*" or ""

  if vim.wo.previewwindow then
    status = status .. "%<" .. vim.fn.pathshorten(require("lbrayner.path").full_path())
  elseif require("lbrayner").buf_is_scratch() and vim.api.nvim_buf_get_name(0) == "" then
    status = status .. "%<%5*%f%*"
  elseif vim.bo.buftype ~= "" then
    status = status .. "%<%5*" .. M.get_buffer_name({ tail = true }) .. "%*"
  else
    status = status .. "%<" .. M.get_buffer_name({ tail = true })
  end

  status = status .. (vim.bo.modified and " " or " %1*") .. M.get_status_flag() .. "%*"

  return status
end

function M.get_diagnostics()
  local bufnr = vim.api.nvim_get_current_buf()

  if vim.tbl_isempty(vim.diagnostic.get(bufnr)) then
    return " "
  end

  return "%7*•%*"
end

function M.get_empty()
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

function M.get_version_control()
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
    return string.sub(branch, 1, 24) .. "…" .. string.sub(branch, -5)
  end

  return branch
end

-- margins of 1 column (on both sides)
function M.get_statusline()
  if require("lbrayner.fugitive").is_fugitive_blame() then
    return " Fugitive blame " ..
    "%<%1*%{v:lua.require'lbrayner.statusline'.get_status_flag()}%*%=" .. get_buffer_position()
  end

  local leftline = " "
  if vim.wo.previewwindow then
    leftline = leftline .. "%5*%w%* "
  end

  if vim.b.fugitive_type and vim.b.fugitive_type == "index" then -- Fugitive summary
    local dir = vim.fn.pathshorten(require("lbrayner.fugitive").get_fugitive_git_dir())
    leftline = leftline .. "%6*" .. dir .. "$%* %<" .. "Fugitive summary " ..
    "%1*%{v:lua.require'lbrayner.statusline'.get_status_flag()}%*"
  elseif vim.fn.exists("*FugitiveResult") == 1 and
    not vim.tbl_isempty(vim.fn.FugitiveResult(vim.api.nvim_get_current_buf())) then -- Fugitive temporary buffers
    local fugitive_temp_buf = get_fugitive_temporary_buffer_name()
    local dir = vim.fn.pathshorten(require("lbrayner.fugitive").get_fugitive_git_dir())
    leftline = leftline .. "%6*" .. dir .. "$%* %<" .. fugitive_temp_buf ..
    " %1*%{v:lua.require'lbrayner.statusline'.get_status_flag()}%*"
  elseif require("lbrayner").is_quickfix_or_location_list() then
    leftline = leftline ..
    "%<%5*%f%* %{v:lua.require'lbrayner'.get_quickfix_or_location_list_title()}"
  elseif vim.w.cmdline then
    leftline = leftline .. "%<%5*[Command Line]%*"
  else
    leftline = leftline .. "%{%v:lua.require'lbrayner.statusline'.get_buffer_status()%}"
  end

  local rightline = "%{%v:lua.require'lbrayner.statusline'.get_minor_modes()%}" .. get_buffer_position()

  if vim.bo.buftype ~= "" then
    rightline = rightline ..
    "%( %6*%{v:lua.require'lbrayner.statusline'.get_version_control()}%*%) %2*%{&filetype}%* "
  else
    rightline = rightline ..
    " %{%v:lua.require'lbrayner.statusline'.get_diagnostics()%}" ..
    "%( %6*%{v:lua.require'lbrayner.statusline'.get_version_control()}%*%)" ..
    " %4*%{v:lua.require'lbrayner'.options(&fileencoding, &encoding, '')}%*" ..
    " %4.(%4*%{&fileformat}%*%)" ..
    " %2*%{&filetype}%* "
  end

  return leftline .. " %=" .. rightline
end

function M.get_winbar()
  if require("lbrayner.fugitive").is_fugitive_blame() then
    return " Fugitive blame %<%{v:lua.require'lbrayner.statusline'.get_status_flag()}"
  end

  local statusline = " "
  if vim.wo.previewwindow then
    statusline = statusline .. "%w "
  end

  if vim.b.fugitive_type and vim.b.fugitive_type == "index" then -- Fugitive summary
    local dir = vim.fn.pathshorten(require("lbrayner.fugitive").get_fugitive_git_dir())
    statusline = statusline .. dir .. "$ %<" .. "Fugitive summary " ..
    "%{v:lua.require'lbrayner.statusline'.get_status_flag()}"
  elseif vim.fn.exists("*FugitiveResult") == 1 and
    not vim.tbl_isempty(vim.fn.FugitiveResult(vim.api.nvim_get_current_buf())) then -- Fugitive temporary buffers
    local fugitive_temp_buf = get_fugitive_temporary_buffer_name()
    local dir = vim.fn.pathshorten(require("lbrayner.fugitive").get_fugitive_git_dir())
    statusline = statusline .. dir .. "$ %<" .. fugitive_temp_buf ..
    " %{v:lua.require'lbrayner.statusline'.get_status_flag()}"
  elseif require("lbrayner").is_quickfix_or_location_list() then
    statusline = statusline .. "%<%f %{v:lua.require'lbrayner'.get_quickfix_or_location_list_title()}"
  elseif vim.w.cmdline then
    statusline = ""
  else
    if vim.wo.previewwindow then
      statusline = statusline .. "%<" .. vim.fn.pathshorten(require("lbrayner.path").full_path())
    else
      -- margins of 1 column, space and status flag
      statusline = statusline ..
      "%<%{v:lua.require'lbrayner'.truncate_filename(" ..
      "v:lua.require'lbrayner.statusline'.get_buffer_name(), winwidth('%') - 4)}"
    end
    statusline = statusline .. " %{v:lua.require'lbrayner.statusline'.get_status_flag()}"
  end

  return statusline
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
  local success, theme = pcall(require, "lbrayner.statusline.themes." .. name)
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

function M.set_minor_modes(bufnr, mode, action)
  assert(type(bufnr) == "number" and bufnr > 0, "'bufnr' must be a positive number")
  assert(type(mode) == "string", "'mode' must be a string")
  assert(action == "append" or action == "remove", "invalid 'action': " .. tostring(action))

  local lbrayner = vim.b[bufnr].lbrayner or vim.empty_dict()
  local data = vim.tbl_get(lbrayner, "statusline", "modes", "data") or vim.empty_dict()

  if action == "append" then
    data[mode] = true
  elseif action == "remove" then
    data[mode] = nil
  end

  local keys = vim.tbl_keys(data)
  table.sort(keys)

  lbrayner = vim.tbl_deep_extend("keep", {
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

local function is_actual_curwin() -- {{{
  -- This variable is defined by the runtime.
  -- :h g:actual_curwin
  if vim.g.actual_curwin and vim.g.actual_curwin ~= vim.api.nvim_get_current_win() then
    return false
  end

  return true
end -- }}}

local function define_status_line() -- {{{
  if is_actual_curwin() then
    vim.wo.statusline = M.get_statusline()
  end
end -- }}}

local statusline = vim.api.nvim_create_augroup("statusline", { clear = true })

vim.api.nvim_create_autocmd("CmdlineEnter", {
  pattern = { ":", "/", "?" },
  group = statusline,
  desc = "Command-line modes statusline highlight",
  callback = function(args)
    if args.file == ":" then
      M.highlight_mode("command")
    elseif vim.tbl_contains({ "/", "?" }, args.file) then
      M.highlight_mode("search")
    else
      return
    end
    vim.api.nvim__redraw({ statusline = 1 })
  end,
})

vim.api.nvim_create_autocmd("ColorScheme", {
  group = statusline,
  desc = "Load statusline theme",
  callback = function(args)
    local colorscheme = args.match
    M.load_theme(colorscheme)
  end,
})

vim.api.nvim_create_autocmd("InsertEnter", {
  group = statusline,
  desc = "Insert mode statusline highlight",
  callback = function()
    M.highlight_mode("insert")
  end,
})

vim.api.nvim_create_autocmd("ModeChanged", {
  pattern = [[[^vV\x16]:[vV\x16]*]],
  group = statusline,
  desc = "Visual modes statusline highlight",
  callback = function()
    M.highlight_mode("visual")
  end,
})

vim.api.nvim_create_autocmd("ModeChanged", {
  pattern = "[^n]*:n*",
  group = statusline,
  desc = "Command/Normal mode statusline highlight",
  callback = function()
    M.highlight_mode("normal")
  end,
})

vim.api.nvim_create_autocmd("TermEnter", {
  group = statusline,
  desc = "Terminal mode statusline definition and highlight",
  callback = function()
    M.highlight_mode("terminal")
    local winid = vim.api.nvim_get_current_win()
    vim.schedule(function()
      if vim.api.nvim_win_is_valid(winid) then
        vim.api.nvim_win_call(winid, function()
          vim.wo.statusline = ""
        end)
      end
    end)
  end,
})

vim.api.nvim_create_autocmd("TermLeave", {
  group = statusline,
  desc = "Restore regular statusline",
  callback = define_status_line,
})

vim.api.nvim_create_autocmd("VimEnter", {
  group = statusline,
  desc = "Create statusline autocmds",
  callback = function(args)
    local diagnostic_changed_autocmd

    local function diagnostic_changed(bufnr)
      local function highlight_severity(bufnr)
        local severity = (function(bufnr)
          if vim.tbl_isempty(vim.diagnostic.get(bufnr)) then
            return nil
          end
          for _, level in ipairs(vim.diagnostic.severity) do
            local items =  vim.diagnostic.get(bufnr, { severity = level })
            if not vim.tbl_isempty(items) then
              return level
            end
          end
        end)(bufnr)

        local user7 = vim.api.nvim_get_hl(0, { name = "User7" })

        if not severity then
          vim.api.nvim_set_hl(0, "User7", vim.tbl_deep_extend("keep", { fg = "NONE" }, user7))
          return
        end

        local group = "Diagnostic" .. string.sub(severity, 1, 1) .. string.lower(string.sub(severity, 2))
        local severity_hl = vim.api.nvim_get_hl(0, { name = group })
        vim.api.nvim_set_hl(0, "User7", vim.tbl_deep_extend("keep", { fg = severity_hl.fg }, user7))
      end

      bufnr = bufnr or vim.api.nvim_get_current_buf()
      highlight_severity(bufnr)

      pcall(vim.api.nvim_del_autocmd, diagnostic_changed_autocmd)

      diagnostic_changed_autocmd = vim.api.nvim_create_autocmd("DiagnosticChanged", {
        group = statusline,
        buffer = bufnr,
        desc = "Diagnostic severity statusline highlight",
        callback = function(args)
          local bufnr = args.buf
          highlight_severity(bufnr)
        end,
      })
    end

    vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
      group = statusline,
      desc = "Define window local statusline, buffer-local diagnostic autocmd",
      callback = function(args)
        if require("lbrayner").win_is_floating() then
          -- Statusline is not allowed in floating windows (see :h
          -- api-floatwin). Moreover BufWinEnter and WinEnter are triggered
          -- even when {enter} is false (see :h nvim_open_win).
          return
        end

        local bufnr = args.buf

        diagnostic_changed(bufnr)

        if vim.go.statusline == vim.wo.statusline then
          vim.schedule(define_status_line)
        end
      end,
    })

    vim.schedule(diagnostic_changed)
    vim.schedule(define_status_line)
  end,
})

-- rocks.nvim wasn't synced at least once
if not pcall(require, "neosolarized") then
  -- A statusline theme is required
  M.load_theme("neosolarized")
end

if vim.v.vim_did_enter == 1 then
  vim.api.nvim_exec_autocmds("VimEnter", { group = statusline })
end

return M
