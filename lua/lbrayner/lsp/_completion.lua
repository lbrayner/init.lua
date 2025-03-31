local M = {}
local api = vim.api
local protocol = vim.lsp.protocol
local ms = vim.lsp.protocol.Methods

--- From $VIMRUNTIME local function matches_prefix
--- Some language servers return complementary candidates whose prefixes do not
--- match are also returned. So we exclude completion candidates whose prefix
--- does not match.
local function remove_unmatch_completion_items(items, prefix)
  return vim.tbl_filter(function(item)
    -- tsserver will not always supply a textEdit, so prefix might be '.' (see adjust_start_col)
    if item.commitCharacters and vim.tbl_contains(item.commitCharacters, prefix) then
      return true
    end
    if vim.tbl_get(item, 'textEdit', 'newText') and
      item.textEdit.newText ~= '' and
      vim.startswith(item.textEdit.newText, prefix) then
      return true
    end
    if item.insertText and item.insertText ~= '' and vim.startswith(item.insertText, prefix) then
      return true
    end
    if item.textEditText and item.textEditText ~= '' and vim.startswith(item.textEditText, prefix) then
      return true
    end
    return vim.startswith(item.label, prefix)
  end, items)
end

--- Returns text that should be inserted when selecting completion item. The
--- precedence is as follows: textEdit.newText > insertText > label
---
--- See https://microsoft.github.io/language-server-protocol/specifications/specification-current/#textDocument_completion
---
---@param item lsp.CompletionItem
---@return string
local function get_completion_word(item)
  if item.textEdit ~= nil and item.textEdit.newText ~= nil and item.textEdit.newText ~= '' then
    return item.textEdit.newText
  elseif item.insertText ~= nil and item.insertText ~= '' then
    return item.insertText
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
function M._lsp_to_complete_items(result, prefix, client_id)
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
    local info = ''
    local documentation = completion_item.documentation
    if documentation then
      if type(documentation) == 'string' and documentation ~= '' then
        info = documentation
      elseif type(documentation) == 'table' and type(documentation.value) == 'string' then
        info = documentation.value
      else
        vim.notify(
          ('invalid documentation value %s'):format(vim.inspect(documentation)),
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
      kind = protocol.CompletionItemKind[completion_item.kind] or 'Unknown',
      menu = completion_item.detail or '',
      info = #info > 0 and info or nil,
      icase = 1,
      dup = 1,
      empty = 1,
      user_data = {
        nvim = {
          lsp = {
            client_id = client_id,
            completion_item = completion_item,
          },
        },
      },
    })
  end

  return matches
end

function M._convert_results(
  line,
  cursor_col,
  client_start_boundary,
  result,
  client_id
)
  --
  -- `adjust_start_col` and the language server boundary won't be used
  --
  local candidates = get_items(result)
  local prefix = line:sub(client_start_boundary + 1, cursor_col)
  local matches = M._lsp_to_complete_items(result, prefix, client_id)
  return matches
end

---@param findstart integer 0 or 1, decides behavior
---@param base integer findstart=0, text to match against
---@return integer|table Decided by {findstart}:
--- - findstart=0: column where the completion starts, or -2 or -3
--- - findstart=1: list of matches (actually just calls |complete()|)
function M.omnifunc(findstart, base)
  assert(base) -- silence luals
  local bufnr = api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr, method = ms.textDocument_completion })
  local remaining = #clients
  if remaining == 0 then
    return findstart == 1 and -1 or {}
  end

  local winid = api.nvim_get_current_win()
  local cursor = api.nvim_win_get_cursor(winid)
  local lnum = cursor[1] - 1
  local cursor_col = cursor[2]
  local line = api.nvim_get_current_line()
  -- print('line', vim.inspect(line)) -- TODO debug
  local line_to_cursor = line:sub(1, cursor_col)
  local client_start_boundary = vim.fn.match(line_to_cursor, '\\k*$') --[[@as integer]]
  local items = {}

  local function on_done()
    local mode = api.nvim_get_mode()['mode']
    if mode == 'i' or mode == 'ic' then
      -- print('client_start_boundary', vim.inspect(client_start_boundary)) -- TODO debug
      vim.fn.complete(client_start_boundary + 1, items)
    end
  end

  local util = vim.lsp.util
  for _, client in ipairs(clients) do
    local params = util.make_position_params(winid, client.offset_encoding)
    client:request(ms.textDocument_completion, params, function(err, result)
      -- print('params', vim.inspect(params)) -- TODO debug
      -- do -- TODO debug
      --   local fd = assert(vim.uv.fs_open('/var/tmp/textDocument_completion_result.lua', 'w', 438))
      --   vim.uv.fs_write(fd, vim.inspect(result))
      --   assert(vim.uv.fs_close(fd))
      -- end
      if err then
        vim.lsp.log.warn(err.message)
      end
      if result and vim.fn.mode() == 'i' then
        local matches
        matches = M._convert_results(
          line,
          cursor_col,
          client_start_boundary,
          result,
          client.id
        )
        -- print('matches', vim.inspect(matches)) -- TODO debug
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

local complete
local completion_accepted

vim.keymap.set("i", "<C-Y>", function()
  if vim.fn.pumvisible() == 1 then
    completion_accepted = true
  end
  return "<C-Y>"
end, { expr = true })

local lsp_completion = vim.api.nvim_create_augroup("lsp_completion", { clear = true })

vim.api.nvim_create_autocmd("CompleteDonePre", {
  group = lsp_completion,
  desc = "LSP completion",
  callback = function(args)
    if completion_accepted then
      completion_accepted = nil
    else
      return
    end

    local completed_item = vim.v.completed_item
    local lsp = vim.tbl_get(completed_item, "user_data", "nvim", "lsp")

    if not lsp then
      return
    end

    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(lsp.client_id)
    local completion_item = lsp.completion_item

    -- From cmp_nvim_lsp
    if vim.tbl_get(client.capabilities, "textDocument", "completion", "resolveSupport") and
      vim.tbl_get(client.server_capabilities, "completionProvider", "resolveProvider") then
      client:request("completionItem/resolve", completion_item, function(_, result)
        completion_item = result or completion_item
        complete(client, bufnr, completed_item, completion_item)
      end)
      return
    end

    complete(client, bufnr, completed_item, completion_item)
  end
})

complete = function(client, bufnr, completed_item, completion_item)
  local is_snippet = completion_item.insertTextFormat == vim.lsp.protocol.InsertTextFormat.Snippet
  local new_text
  local word

  if completion_item.textEdit then
    -- Delayed completion
    -- Do textEdit, then possibly additionalTextEdits
    -- Typically an auto-import
    local text_edit = completion_item.textEdit
    new_text = text_edit.newText

    if is_snippet then
      text_edit.newText = ""
    end

    if text_edit.replace then -- lsp.InsertReplaceEdit
      text_edit.range = text_edit.replace
    end

    local text_edits = { text_edit }

    if completion_item.additionalTextEdits then
      vim.list_extend(text_edits, completion_item.additionalTextEdits)
    end

    vim.lsp.util.apply_text_edits(text_edits, bufnr, client.offset_encoding)
  elseif completion_item.additionalTextEdits then
    -- Delayed completion
    -- Do additionalTextEdits, then insert insertText
    -- eclipse.jdt.ls postfix snippets
    vim.lsp.util.apply_text_edits(completion_item.additionalTextEdits, bufnr, client.offset_encoding)

    new_text = completion_item.insertText or completion_item.textEditText or completion_item.label

    if not is_snippet then
      vim.api.nvim_put({ new_text }, "", false, true)
    end
  elseif is_snippet then
    -- Expand snippet of a regular completion
    -- textEditText only possible if there are itemDefaults with a range
    new_text = completion_item.insertText or completion_item.label
    word = completed_item.word
  end

  if is_snippet and pcall(require, "snippy") then
    require("snippy").expand_snippet(new_text, word)
  end
end

return M
