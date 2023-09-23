local prefix = require("lbrayner.diagnostic").get_prefix()

local function is_long(bufnr, winid, virt_texts, lnum)
  -- TODO reduce?
  local mess_len = 0
  for _, virt_text in ipairs(virt_texts) do
    mess_len = mess_len + string.len(virt_text[1])
  end
  if mess_len == 0 then
    return false
  end
  -- Dealing with E5555: API call: Index out of bounds
  local success, lines = pcall(vim.api.nvim_buf_get_lines, bufnr, lnum, lnum+1, true)
  if not success then return false end
  local line = lines[1]
  local line_len = string.len(line)
  local winwidth = vim.api.nvim_win_get_width(winid) - 2 - 3 -- sign & column number
  local long = line_len + 1 + mess_len > winwidth
  return long
end

local function handle_long_extmarks(namespace, bufnr, winid)
  local metadata = vim.diagnostic.get_namespace(namespace)
  if not metadata then
    return
  end
  local virt_text_ns = metadata.user_data.virt_text_ns
  if not virt_text_ns then
    return
  end
  local extmarks = vim.api.nvim_buf_get_extmarks(bufnr, virt_text_ns, 0, -1, {
    details = true
  })
  for _, extmark in ipairs(extmarks) do
    local id, lnum, details = extmark[1], extmark[2], extmark[4]
    if not details.virt_text then
      return
    end
    local long = is_long(bufnr, winid, details.virt_text, lnum)
    if long then
      vim.api.nvim_buf_del_extmark(bufnr, virt_text_ns, id)
    end
  end
end

local trunc_virt_text = vim.api.nvim_create_augroup("trunc_virt_text", { clear = true })

vim.api.nvim_create_autocmd({ "VimEnter" }, {
  group = trunc_virt_text,
  callback = function()
    vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
      group = trunc_virt_text,
      callback = function(args)
        local bufnr = args.buf
        local winid = vim.api.nvim_get_current_win()
        for _, namespace in ipairs(vim.tbl_values(vim.api.nvim_get_namespaces())) do
          handle_long_extmarks(namespace, bufnr, winid)
        end
      end,
    })
  end,
})

vim.api.nvim_create_autocmd({ "VimEnter" }, {
  group = trunc_virt_text,
  callback = function()
    vim.api.nvim_create_autocmd({ "WinResized" }, {
      group = trunc_virt_text,
      callback = function(args)
        local winids = vim.v.event.windows
        local wininfos = vim.tbl_filter(function(wininfo)
          return vim.tbl_contains(winids, wininfo.winid)
        end, vim.fn.getwininfo())
        for _, wininfo in ipairs(wininfos) do
          local bufnr = wininfo.bufnr
          local winid = wininfo.winid
          for _, namespace in ipairs(vim.tbl_values(vim.api.nvim_get_namespaces())) do
            handle_long_extmarks(namespace, bufnr, winid)
          end
        end
      end,
    })
  end,
})

if vim.v.vim_did_enter == 1 then
  vim.api.nvim_exec_autocmds("VimEnter", { group = trunc_virt_text })
end

local function get_cursor()
  return vim.api.nvim_win_get_cursor(0)
end

local close_events = { "CursorMoved", "CursorMovedI", "InsertCharPre", "WinScrolled" }

local function open_float()
  return vim.diagnostic.open_float({ close_events = close_events })
end

local function goto_first()
  -- Save the current cursor position
  local line_col = get_cursor()
  -- Move the cursor to the second column
  vim.api.nvim_win_set_cursor(0, { line_col[1], 1 })
  local prev_pos = vim.diagnostic.get_prev_pos()
  -- If there's an anterior diagnostic in the current line, it's in column 1
  if prev_pos and prev_pos[1]+1 == line_col[1] and prev_pos[2] < get_cursor()[2] then
    -- Go to column 1 and open the floating window
    vim.api.nvim_win_set_cursor(0, { line_col[1], 0 })
    -- Scheduling lest CursorMoved is triggered
    return vim.schedule(open_float)
  end
  -- Move the cursor to the beginning of the line
  vim.api.nvim_win_set_cursor(0, { line_col[1], 0 })
  local next_pos = vim.diagnostic.get_next_pos()
  -- If there's no next diagnostic in the current line, there might be one in
  -- column 1
  if not next_pos or next_pos[1]+1 ~= line_col[1] then
    -- If there isn't, restore the cursor
    return open_float() or vim.api.nvim_win_set_cursor(0, line_col)
  end
  -- Move the cursor to the first diagnostic in the line
  vim.api.nvim_win_set_cursor(0, { line_col[1], next_pos[2] })
  -- Scheduling lest CursorMoved is triggered
  return vim.schedule(open_float)
end

local opts = { silent = true }

vim.keymap.set("n", "<Space>e", goto_first, opts)
vim.keymap.set("n", "<Space>E", function()
  vim.diagnostic.open_float({ close_events = close_events, scope = "buffer" })
end, opts)
vim.keymap.set("n", "[d", function()
  vim.diagnostic.goto_prev({ float = { close_events = close_events } })
end, opts)
vim.keymap.set("n", "]d", function()
  vim.diagnostic.goto_next({ float = { close_events = close_events } })
end, opts)

vim.keymap.set("n", "[!", function()
  vim.diagnostic.goto_prev({ float = { close_events = close_events }, severity = {
    min = vim.diagnostic.severity.WARN
  } })
end, opts)
vim.keymap.set("n", "]!", function()
  vim.diagnostic.goto_next({ float = { close_events = close_events }, severity = {
    min = vim.diagnostic.severity.WARN
  } })
end, opts)

local custom_diagnostics = vim.api.nvim_create_augroup("custom_diagnostics", { clear = true })

local err = "DiagnosticSignError"
local war = "DiagnosticSignWarn"
local inf = "DiagnosticSignInfo"
local hin = "DiagnosticSignHint"

if not _G.default_virtual_text_handler then
  _G.default_virtual_text_handler = vim.diagnostic.handlers.virtual_text
end

local function DefaultDiagnostics()
  vim.cmd "highlight DiagnosticError ctermfg=1 guifg=Red"
  vim.cmd "highlight DiagnosticWarn  ctermfg=3 guifg=Orange"
  vim.cmd "highlight DiagnosticInfo  ctermfg=4 guifg=LightBlue"
  vim.cmd "highlight DiagnosticHint  ctermfg=7 guifg=LightGrey"

  vim.fn.sign_define(err, { text="E", texthl=err, linehl="", numhl="" })
  vim.fn.sign_define(war, { text="W", texthl=war, linehl="", numhl="" })
  vim.fn.sign_define(inf, { text="I", texthl=inf, linehl="", numhl="" })
  vim.fn.sign_define(hin, { text="H", texthl=hin, linehl="", numhl="" })

  vim.diagnostic.config({ severity_sort = false, virtual_text = true })

  vim.diagnostic.handlers.virtual_text = _G.default_virtual_text_handler
end

vim.api.nvim_create_user_command("DefaultDiagnostics", DefaultDiagnostics, { nargs = 0 })

local function CustomDiagnostics()
  vim.fn.sign_define(err, { text="", texthl=err, linehl="", numhl=err })
  vim.fn.sign_define(war, { text="", texthl=war, linehl="", numhl=war })
  vim.fn.sign_define(inf, { text="", texthl=inf, linehl="", numhl=inf })
  vim.fn.sign_define(hin, { text="", texthl=hin, linehl="", numhl=hin })

  vim.diagnostic.config({
    severity_sort = true,
    virtual_text = {
      prefix = prefix,
      spacing = 0,
    },
  })

  vim.diagnostic.handlers.virtual_text = {
    show = function(namespace, bufnr, diagnostics, opts)
      _G.default_virtual_text_handler.show(namespace, bufnr, diagnostics, opts)
      local wininfos = vim.tbl_filter(function(wininfo)
        return wininfo.bufnr == bufnr
      end, vim.fn.getwininfo())
      for _, wininfo in ipairs(wininfos) do
        local winid = wininfo.winid
        handle_long_extmarks(namespace, bufnr, winid)
      end
    end,
    hide = function(namespace, bufnr)
      _G.default_virtual_text_handler.hide(namespace, bufnr)
    end,
  }
end

vim.api.nvim_create_user_command("CustomDiagnostics", CustomDiagnostics, { nargs = 0 })

vim.api.nvim_create_autocmd({ "VimEnter" }, {
  group = custom_diagnostics,
  callback = CustomDiagnostics,
})
