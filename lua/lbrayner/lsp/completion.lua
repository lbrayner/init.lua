local M = {}

local api = vim.api
local lsp = vim.lsp
local protocol = lsp.protocol
local ms = protocol.Methods

local rtt_ms = 50
local ns_to_ms = 0.000001

--- @nodoc
--- @class vim.lsp.completion.Context
local Context = {
  cursor = nil, --- @type [integer, integer]?
  last_request_time = nil, --- @type integer?
  pending_requests = {}, --- @type function[]
  isIncomplete = false,
}

--- @nodoc
function Context:cancel_pending()
  for _, cancel in ipairs(self.pending_requests) do
    cancel()
  end

  self.pending_requests = {}
end

--- @nodoc
function Context:reset()
  -- Note that the cursor isn't reset here, it needs to survive a `CompleteDone` event.
  self.isIncomplete = false
  self.last_request_time = nil
  self:cancel_pending()
end

--- @param clients table<integer, vim.lsp.Client> # keys != client_id
--- @param bufnr integer
--- @param win integer
--- @param ctx? lsp.CompletionContext
--- @param callback fun(responses: table<integer, { err: lsp.ResponseError, result: vim.lsp.CompletionResult }>)
--- @return function # Cancellation function
local function request(clients, bufnr, win, ctx, callback)
  local responses = {} --- @type table<integer, { err: lsp.ResponseError, result: any }>
  local request_ids = {} --- @type table<integer, integer>
  local remaining_requests = vim.tbl_count(clients)

  for _, client in pairs(clients) do
    local client_id = client.id
    local params = lsp.util.make_position_params(win, client.offset_encoding)
    --- @cast params lsp.CompletionParams
    params.context = ctx
    local ok, request_id = client:request(ms.textDocument_completion, params, function(err, result)
      responses[client_id] = { err = err, result = result }
      remaining_requests = remaining_requests - 1
      if remaining_requests == 0 then
        callback(responses)
      end
    end, bufnr)

    if ok then
      request_ids[client_id] = request_id
    end
  end

  return function()
    for client_id, request_id in pairs(request_ids) do
      local client = lsp.get_client_by_id(client_id)
      if client then
        client:cancel_request(request_id)
      end
    end
  end
end

--- Applies the given defaults to the completion item, modifying it in place.
---
--- @param item lsp.CompletionItem
--- @param defaults lsp.ItemDefaults?
local function apply_defaults(item, defaults)
  if not defaults then
    return
  end

  item.insertTextFormat = item.insertTextFormat or defaults.insertTextFormat
  item.insertTextMode = item.insertTextMode or defaults.insertTextMode
  item.data = item.data or defaults.data
  if defaults.editRange then
    local textEdit = item.textEdit or {}
    item.textEdit = textEdit
    textEdit.newText = textEdit.newText or item.textEditText or item.insertText or item.label
    if defaults.editRange.start then
      textEdit.range = textEdit.range or defaults.editRange
    elseif defaults.editRange.insert then
      textEdit.insert = defaults.editRange.insert
      textEdit.replace = defaults.editRange.replace
    end
  end
end

--- @param result vim.lsp.CompletionResult
--- @return lsp.CompletionItem[]
local function get_items(result)
  if result.items then
    -- When we have a list, apply the defaults and return an array of items.
    for _, item in ipairs(result.items) do
      ---@diagnostic disable-next-line: param-type-mismatch
      apply_defaults(item, result.itemDefaults)
    end
    return result.items
  else
    -- Else just return the items as they are.
    return result
  end
end

--- @param window integer
--- @param warmup integer
--- @return fun(sample: number): number
local function exp_avg(window, warmup)
  local count = 0
  local sum = 0
  local value = 0

  return function(sample)
    if count < warmup then
      count = count + 1
      sum = sum + sample
      value = sum / count
    else
      local factor = 2.0 / (window + 1)
      value = value * (1 - factor) + sample * factor
    end
    return value
  end
end
local compute_new_average = exp_avg(10, 10)

--- @type uv.uv_timer_t?
local completion_timer = nil

local function reset_timer()
  if completion_timer then
    completion_timer:stop()
    completion_timer:close()
  end

  completion_timer = nil
end

--- @param lnum integer 0-indexed
--- @param line string
--- @param items lsp.CompletionItem[]
--- @param encoding string
--- @return integer?
local function adjust_start_col(lnum, line, items, encoding)
  local min_start_char = nil
  for _, item in pairs(items) do
    local range = vim.tbl_get(item, 'textEdit', 'range')
    if range and range.start.line == lnum then
      if min_start_char and min_start_char ~= range.start.character then
        return nil
      end
      min_start_char = range.start.character
    end
  end
  if min_start_char then
    return vim.str_byteindex(line, encoding, min_start_char, false)
  else
    return nil
  end
end

--- @private
--- @param line string line content
--- @param lnum integer 0-indexed line number
--- @param cursor_col integer
--- @param client_id integer client ID
--- @param client_start_boundary integer 0-indexed word boundary
--- @param server_start_boundary? integer 0-indexed word boundary, based on textEdit.range.start.character
--- @param result vim.lsp.CompletionResult
--- @param encoding string
--- @return table[] matches
--- @return integer? server_start_boundary
function M._convert_results(
  line,
  lnum,
  cursor_col,
  client_id,
  client_start_boundary,
  server_start_boundary,
  result,
  encoding
)
  -- Completion response items may be relative to a position different than `client_start_boundary`.
  -- Concrete example, with lua-language-server:
  --
  -- require('plenary.asy|
  --         ▲       ▲   ▲
  --         │       │   └── cursor_pos:                     20
  --         │       └────── client_start_boundary:          17
  --         └────────────── textEdit.range.start.character: 9
  --                                 .newText = 'plenary.async'
  --                  ^^^
  --                  prefix (We'd remove everything not starting with `asy`,
  --                  so we'd eliminate the `plenary.async` result
  --
  -- `adjust_start_col` is used to prefer the language server boundary.
  --
  local candidates = get_items(result)
  local curstartbyte = adjust_start_col(lnum, line, candidates, encoding)
  if server_start_boundary == nil then
    server_start_boundary = curstartbyte
  elseif curstartbyte ~= nil and curstartbyte ~= server_start_boundary then
    server_start_boundary = client_start_boundary
  end
  local prefix = line:sub((server_start_boundary or client_start_boundary) + 1, cursor_col)
  local matches = vim.lsp.completion._lsp_to_complete_items(result, prefix, client_id)
  return matches, server_start_boundary
end

--- @param bufnr integer
--- @param clients vim.lsp.Client[]
--- @param ctx? lsp.CompletionContext
local function trigger(bufnr, clients, ctx)
  reset_timer()
  Context:cancel_pending()

  if tonumber(vim.fn.pumvisible()) == 1 and not Context.isIncomplete then
    return
  end

  local win = api.nvim_get_current_win()
  local cursor_row, cursor_col = unpack(api.nvim_win_get_cursor(win)) --- @type integer, integer
  local line = api.nvim_get_current_line()
  local line_to_cursor = line:sub(1, cursor_col)
  local word_boundary = vim.fn.match(line_to_cursor, '\\k*$')
  local start_time = vim.uv.hrtime()
  Context.last_request_time = start_time

  local cancel_request = request(clients, bufnr, win, ctx, function(responses)
    local end_time = vim.uv.hrtime()
    rtt_ms = compute_new_average((end_time - start_time) * ns_to_ms)

    Context.pending_requests = {}
    Context.isIncomplete = false

    local row_changed = api.nvim_win_get_cursor(win)[1] ~= cursor_row
    local mode = api.nvim_get_mode().mode
    if row_changed or not (mode == 'i' or mode == 'ic') then
      return
    end

    local matches = {}
    local server_start_boundary --- @type integer?
    for client_id, response in pairs(responses) do
      if response.err then
        vim.notify_once(response.err.message, vim.log.levels.WARN)
      end

      local result = response.result
      if result then
        Context.isIncomplete = Context.isIncomplete or result.isIncomplete
        local client = lsp.get_client_by_id(client_id)
        local encoding = client and client.offset_encoding or 'utf-16'
        local client_matches
        client_matches, server_start_boundary = M._convert_results(
          line,
          cursor_row - 1,
          cursor_col,
          client_id,
          word_boundary,
          nil,
          result,
          encoding
        )
        vim.list_extend(matches, client_matches)
      end
    end
    local start_col = (server_start_boundary or word_boundary) + 1
    Context.cursor = { cursor_row, start_col }
    vim.fn.complete(start_col, matches)
  end)

  table.insert(Context.pending_requests, cancel_request)
end

--- Implements 'omnifunc' compatible LSP completion.
---
--- @see |complete-functions|
--- @see |complete-items|
--- @see |CompleteDone|
---
--- @param findstart integer 0 or 1, decides behavior
--- @param base integer findstart=0, text to match against
---
--- @return integer|table Decided by {findstart}:
--- - findstart=0: column where the completion starts, or -2 or -3
--- - findstart=1: list of matches (actually just calls |complete()|)
function M._omnifunc(findstart, base)
  vim.lsp.log.debug('omnifunc.findstart', { findstart = findstart, base = base })
  assert(base) -- silence luals
  local bufnr = api.nvim_get_current_buf()
  local clients = lsp.get_clients({ bufnr = bufnr, method = ms.textDocument_completion })
  local remaining = #clients
  if remaining == 0 then
    return findstart == 1 and -1 or {}
  end

  trigger(bufnr, clients, { triggerKind = protocol.CompletionTriggerKind.Invoked })

  -- Return -2 to signal that we should continue completion so that we can
  -- async complete.
  return -2
end

return M
