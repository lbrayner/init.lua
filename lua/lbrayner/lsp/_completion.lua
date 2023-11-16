local M = {}

--- From local function matches_prefix
---@private
--- Some language servers return complementary candidates whose prefixes do not
--- match are also returned. So we exclude completion candidates whose prefix
--- does not match.
local function remove_unmatch_completion_items(items, prefix)
  return vim.tbl_filter(function(item)
    -- tsserver will not always supply a textEdit, so prefix might be "." (see adjust_start_col)
    if item.commitCharacters and vim.tbl_contains(item.commitCharacters, prefix) then
      return true
    end
    if vim.tbl_get(item, "textEdit", "newText") and
      item.textEdit.newText ~= "" and
      vim.startswith(item.textEdit.newText, prefix) then
      return true
    end
    if item.insertText and item.insertText ~= "" and vim.startswith(item.insertText, prefix) then
      return true
    end
    if item.textEditText and item.textEditText ~= "" and vim.startswith(item.textEditText, prefix) then
      return true
    end
    return vim.startswith(item.label, prefix)
  end, items)
end

local protocol = vim.lsp.protocol

--- Returns text that should be inserted when selecting completion item. The
--- precedence is as follows: textEdit.newText > insertText > label
---
--- See https://microsoft.github.io/language-server-protocol/specifications/specification-current/#textDocument_completion
---
---@param item lsp.CompletionItem
---@return string
local function get_completion_word(item)
  if item.textEdit ~= nil and item.textEdit.newText ~= nil and item.textEdit.newText ~= '' then
    local insert_text_format = protocol.InsertTextFormat[item.insertTextFormat]
    if insert_text_format == 'PlainText' or insert_text_format == nil then
      return item.textEdit.newText
    else
      return M.parse_snippet(item.textEdit.newText)
    end
  elseif item.insertText ~= nil and item.insertText ~= '' then
    local insert_text_format = protocol.InsertTextFormat[item.insertTextFormat]
    if insert_text_format == 'PlainText' or insert_text_format == nil then
      return item.insertText
    else
      return M.parse_snippet(item.insertText)
    end
  end
  return item.label
end

---@param result lsp.CompletionList|lsp.CompletionItem[]
---@return lsp.CompletionItem[]
local function get_items(result)
  if result.items then
    return result.items
  end
  return result
end

--- Turns the result of a `textDocument/completion` request into vim-compatible
--- |complete-items|.
---
---@param result lsp.CompletionList|lsp.CompletionItem[] Result of `textDocument/completion`
---@param prefix string prefix to filter the completion items
---@return table[]
---@see complete-items
function M._lsp_to_complete_items(result, prefix)
  local items = get_items(result)
  if vim.tbl_isempty(items) then
    return {}
  end

  items = remove_unmatch_completion_items(items, prefix)
  table.sort(items, function(a, b)
    return (a.sortText or a.label) < (b.sortText or b.label)
  end)

  local matches = {}

  for _, completion_item in ipairs(items) do
    local info = ""
    local documentation = completion_item.documentation
    if documentation then
      if type(documentation) == "string" and documentation ~= "" then
        info = documentation
      elseif type(documentation) == "table" and type(documentation.value) == "string" then
        info = documentation.value
      else
        vim.notify(
          ("invalid documentation value %s"):format(vim.inspect(documentation)),
          vim.log.levels.WARN
        )
      end
    end

    local defaults = result.itemDefaults or {}

    -- From nvim-cmp
    if defaults.data then
      completion_item.data = completion_item.data or defaults.data
    end

    if defaults.commitCharacters then
      completion_item.commitCharacters = completion_item.commitCharacters or defaults.commitCharacters
    end

    if defaults.insertTextFormat then
      completion_item.insertTextFormat = completion_item.insertTextFormat or defaults.insertTextFormat
    end

    if defaults.insertTextMode then
      completion_item.insertTextMode = completion_item.insertTextMode or defaults.insertTextMode
    end

    if defaults.editRange then
      if not completion_item.textEdit then
        if defaults.editRange.insert then
          completion_item.textEdit = {
            insert = defaults.editRange.insert,
            replace = defaults.editRange.replace,
            newText = completion_item.textEditText or completion_item.label,
          }
        else
          completion_item.textEdit = {
            range = defaults.editRange, --[[@as lsp.Range]]
            newText = completion_item.textEditText or completion_item.label,
          }
        end
      end
    end

    local word = prefix -- Delayed completion

    if not completion_item.textEdit and not completion_item.additionalTextEdits then
      word = get_completion_word(completion_item) -- Regular completion
    end

    table.insert(matches, {
      word = word,
      abbr = completion_item.label,
      kind = protocol.CompletionItemKind[completion_item.kind] or "Unknown",
      menu = completion_item.detail or "",
      info = #info > 0 and info or nil,
      icase = 1,
      dup = 1,
      empty = 1,
      user_data = {
        nvim = {
          lsp = {
            completion_item = completion_item,
          },
        },
      },
    })
  end

  return matches
end

---@param items lsp.CompletionItem[]
local function adjust_start_col(lnum, line, items, encoding)
  local min_start_char = nil
  local no_start_char
  for _, item in pairs(items) do
    local range = vim.tbl_get(item, "textEdit", "range")
    if not range then
      range = vim.tbl_get(item, "textEdit", "replace")
    end
    if item.filterText == nil and range and range.start.line == lnum - 1 then
      if min_start_char and min_start_char ~= range.start.character then
        return nil
      end
      min_start_char = range.start.character
    else
      no_start_char = true
    end
    if min_start_char and no_start_char then
      return nil
    end
  end
  if min_start_char then
    return vim.lsp.util._str_byteindex_enc(line, min_start_char, encoding)
  else
    return nil
  end
end

local ms = vim.lsp.protocol.Methods

---@param findstart integer 0 or 1, decides behavior
---@param base integer findstart=0, text to match against
---@return integer|table Decided by {findstart}:
--- - findstart=0: column where the completion starts, or -2 or -3
--- - findstart=1: list of matches (actually just calls |complete()|)
function M.omnifunc(findstart, base)
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr, method = ms.textDocument_completion })
  local remaining = #clients
  if remaining == 0 then
    return findstart == 1 and -1 or {}
  end

  local log = require("vim.lsp.log")
  -- Then, perform standard completion request
  if log.info() then
    log.info("base ", base)
  end

  local win = vim.api.nvim_get_current_win()
  local pos = vim.api.nvim_win_get_cursor(0)
  local line = vim.api.nvim_get_current_line()
  local line_to_cursor = line:sub(1, pos[2])
  log.trace("omnifunc.line", pos, line)

  local word_boundary = vim.fn.match(line_to_cursor, "\\k*$") + 1 --[[@as integer]]
  local items = {}

  local function on_done()
    local mode = vim.api.nvim_get_mode()["mode"]
    if mode == "i" or mode == "ic" then
      -- print("word_boundary "..vim.inspect(word_boundary)) -- TODO debug
      vim.fn.complete(word_boundary, items)
    end
  end

  local util = vim.lsp.util
  for _, client in ipairs(clients) do
    local params = util.make_position_params(win, client.offset_encoding)
    client.request(ms.textDocument_completion, params, function(err, result)
      -- print("params "..vim.inspect(params)) -- TODO debug
      -- print("result "..vim.inspect(result)) -- TODO debug
      -- do -- TODO debug
      --   local fd = assert(vim.uv.fs_open("/var/tmp/textDocument_completion_result.lua", "w", 438))
      --   vim.uv.fs_write(fd, vim.inspect(result))
      --   assert(vim.uv.fs_close(fd))
      -- end
      if err then
        log.warn(err.message)
      end
      if result and vim.fn.mode() == "i" then
        --
        -- `adjust_start_col` and the language server boundary won't be used
        --
        local encoding = client.offset_encoding
        local candidates = get_items(result)
        local prefix = line_to_cursor:sub(word_boundary)
        -- print("line "..vim.inspect(line)) -- TODO debug
        local matches = M._lsp_to_complete_items(result, prefix)
        -- print("matches "..vim.inspect(matches)) -- TODO debug
        vim.list_extend(items, matches)
      end
      remaining = remaining - 1
      if remaining == 0 then
        vim.schedule(on_done)
      end
    end, bufnr)
  end

  -- Return -2 to signal that we should continue completion so that we can
  -- async complete.
  return -2
end

return M
