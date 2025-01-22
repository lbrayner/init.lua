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

vim.api.nvim_create_autocmd("VimEnter", {
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

    vim.api.nvim_create_autocmd("WinResized", {
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

local close_events = require("lbrayner").get_close_events()
local opts = { silent = true }

vim.keymap.set("n", "<Space>d", function() -- Go to first line diagnostic
  local line_col = vim.api.nvim_win_get_cursor(0)
  local line_diagnostics = vim.diagnostic.get(0, { lnum = line_col[1]-1 })
  local _, first = next(line_diagnostics)

  if first then
    vim.diagnostic.jump({ diagnostic = first, float = { close_events = close_events } })
  end
end, opts)
vim.keymap.set("n", "<Space>D", function()
  vim.diagnostic.open_float({ close_events = close_events, scope = "buffer" })
end, opts)
vim.keymap.set("n", "[d", function()
  vim.diagnostic.jump({ count = -1, float = { close_events = close_events } })
end, opts)
vim.keymap.set("n", "]d", function()
  vim.diagnostic.jump({ count = 1, float = { close_events = close_events } })
end, opts)

vim.keymap.set("n", "[!", function()
  vim.diagnostic.jump({ count = -1, float = { close_events = close_events }, severity = {
    min = vim.diagnostic.severity.WARN
  } })
end, opts)
vim.keymap.set("n", "]!", function()
  vim.diagnostic.jump({ count = 1, float = { close_events = close_events }, severity = {
    min = vim.diagnostic.severity.WARN
  } })
end, opts)

local custom_diagnostics = vim.api.nvim_create_augroup("custom_diagnostics", { clear = true })

local err = "DiagnosticSignError"
local war = "DiagnosticSignWarn"
local inf = "DiagnosticSignInfo"
local hin = "DiagnosticSignHint"

local ERR = vim.diagnostic.severity.ERROR
local WAR = vim.diagnostic.severity.WARN
local INF = vim.diagnostic.severity.INFO
local HIN = vim.diagnostic.severity.HINT

if not _G.default_virtual_text_handler then
  _G.default_virtual_text_handler = vim.diagnostic.handlers.virtual_text
end

local function DefaultDiagnostics()
  vim.cmd "highlight DiagnosticError guifg=Red"
  vim.cmd "highlight DiagnosticWarn  guifg=Orange"
  vim.cmd "highlight DiagnosticInfo  guifg=LightBlue"
  vim.cmd "highlight DiagnosticHint  guifg=LightGrey"

  vim.diagnostic.config({
    signs = {
      text = {
        [ERR] = "E",
        [WAR] = "W",
        [INF] = "I",
        [HIN] = "H",
      },
      texthl = {
        [ERR] = err,
        [WAR] = war,
        [INF] = inf,
        [HIN] = hin,
      },
      linehl = {
        [ERR] = "",
        [WAR] = "",
        [INF] = "",
        [HIN] = "",
      },
      numhl = {
        [ERR] = "",
        [WAR] = "",
        [INF] = "",
        [HIN] = "",
      },
    },
    severity_sort = false,
    virtual_text = true
  })

  vim.diagnostic.handlers.virtual_text = _G.default_virtual_text_handler
end

vim.api.nvim_create_user_command("DefaultDiagnostics", DefaultDiagnostics, { nargs = 0 })

local function CustomDiagnostics()
  vim.diagnostic.config({
    signs = {
      text = {
        [ERR] = "",
        [WAR] = "",
        [INF] = "",
        [HIN] = "",
      },
      texthl = {
        [ERR] = err,
        [WAR] = war,
        [INF] = inf,
        [HIN] = hin,
      },
      linehl = {
        [ERR] = "",
        [WAR] = "",
        [INF] = "",
        [HIN] = "",
      },
      numhl = {
        [ERR] = err,
        [WAR] = war,
        [INF] = inf,
        [HIN] = hin,
      },
    },
    severity_sort = true,
    virtual_text = {
      prefix = "•",
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

vim.api.nvim_create_autocmd("VimEnter", {
  group = custom_diagnostics,
  callback = CustomDiagnostics,
})
