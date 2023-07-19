local protocol = require('vim.lsp.protocol')
local util = require('vim.lsp.util')

local M = {}

--- From vim.lsp.util
---@private
--- Sorts by CompletionItem.sortText.
---
--see https://microsoft.github.io/language-server-protocol/specifications/specification-current/#textDocument_completion
local function sort_completion_items(items)
  table.sort(items, function(a, b)
    return (a.sortText or a.label) < (b.sortText or b.label)
  end)
end

--- From vim.lsp.util
---@private
--- Returns text that should be inserted when selecting completion item. The
--- precedence is as follows: textEdit.newText > insertText > label
--see https://microsoft.github.io/language-server-protocol/specifications/specification-current/#textDocument_completion
local function get_completion_word(item)
  if item.textEdit ~= nil and item.textEdit.newText ~= nil and item.textEdit.newText ~= '' then
    local insert_text_format = protocol.InsertTextFormat[item.insertTextFormat]
    if insert_text_format == 'PlainText' or insert_text_format == nil then
      return item.textEdit.newText
    else
      return util.parse_snippet(item.textEdit.newText)
    end
  elseif item.insertText ~= nil and item.insertText ~= '' then
    local insert_text_format = protocol.InsertTextFormat[item.insertTextFormat]
    if insert_text_format == 'PlainText' or insert_text_format == nil then
      return item.insertText
    else
      return util.parse_snippet(item.insertText)
    end
  end
  return item.label
end

--- From vim.lsp.util
---@private
--- Some language servers return complementary candidates whose prefixes do not
--- match are also returned. So we exclude completion candidates whose prefix
--- does not match.
local function remove_unmatch_completion_items(items, prefix)
  return vim.tbl_filter(function(item)
    if vim.tbl_get(item, "textEdit", "newText") and
      item.textEdit.newText ~= "" and
      vim.startswith(item.textEdit.newText, prefix) then
      return true
    end
    if item.insertText and item.insertText ~= "" and vim.startswith(item.insertText, prefix) then
      return true
    end
    return vim.startswith(item.label, prefix)
  end, items)
end

function M.text_document_completion_list_to_complete_items(result, prefix)
  local items = util.extract_completion_items(result)
  if vim.tbl_isempty(items) then
    return {}
  end

  items = remove_unmatch_completion_items(items, prefix)
  sort_completion_items(items)

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

    local word = get_completion_word(completion_item)
    local is_snippet = protocol.InsertTextFormat[completion_item.insertTextFormat] == 'Snippet'
    local delayed_completion = is_snippet and completion_item.additionalTextEdits and #prefix > 0
    table.insert(matches, {
      -- Delayed completion due to ecplise.jdt.ls's off-spec usage of additionalTextEdits
      word = delayed_completion and prefix or word,
      abbr = completion_item.label,
      kind = util._get_completion_item_kind_name(completion_item.kind),
      menu = completion_item.detail or '',
      info = #info > 0 and info or nil,
      icase = 1,
      dup = 1,
      empty = 1,
      user_data = {
        nvim = {
          lsp = {
            completion_item = completion_item,
            delayed_completion = delayed_completion and { completion_word = word } or nil,
          },
        },
      },
    })
  end

  return matches
end

return M
