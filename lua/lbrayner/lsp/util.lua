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

function M.text_document_completion_list_to_complete_items(result, prefix)
  local items = util.extract_completion_items(result)
  if vim.tbl_isempty(items) then
    return {}
  end

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

    local defaults = result.itemDefaults or {}

    -- From nvim-cmp
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

    table.insert(matches, {
      word = prefix, -- Delayed completion
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
          },
        },
      },
    })
  end

  return matches
end

return M
