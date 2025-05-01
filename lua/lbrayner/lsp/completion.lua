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
        client_matches, server_start_boundary = vim.lsp.completion._convert_results(
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
