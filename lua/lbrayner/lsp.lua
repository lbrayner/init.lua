local M = {}

-- From cmp_nvim_lsp
function M.default_capabilities()
  return {
    textDocument = {
      completion = {
        completionItem = {
          commitCharactersSupport = true,
          deprecatedSupport = true,
          insertReplaceSupport = true,
          insertTextModeSupport = {
            valueSet = { 1, 2 }
          },
          labelDetailsSupport = true,
          preselectSupport = true,
          resolveSupport = {
            properties = {
              "additionalTextEdits",
              "detail",
              "documentation",
              "filterText",
              "insertText",
              "insertTextFormat",
              "insertTextMode",
              "sortText",
              "textEdit",
            }
          },
          snippetSupport = true,
          tagSupport = {
            valueSet = { 1 }
          }
        },
        completionList = {
          itemDefaults = {
            "commitCharacters",
            "data",
            "editRange",
            "insertTextFormat",
            "insertTextMode",
          }
        },
        contextSupport = true,
        dynamicRegistration = false,
        insertTextMode = 1
      }
    }
  }
end

---@private
local function adjust_start_col(lnum, line, items, encoding)
  local min_start_char = nil
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
    end
  end
  if min_start_char then
    return vim.lsp.util._str_byteindex_enc(line, min_start_char, encoding)
  else
    return nil
  end
end

--- From vim.lsp
--- Implements 'omnifunc' compatible LSP completion.
---
---@see |complete-functions|
---@see |complete-items|
---@see |CompleteDone|
---
---@param findstart integer 0 or 1, decides behavior
---@param base integer findstart=0, text to match against
---
---@return integer|table Decided by {findstart}:
--- - findstart=0: column where the completion starts, or -2 or -3
--- - findstart=1: list of matches (actually just calls |complete()|)
function M.omnifunc(findstart, base)
  local bufnr = vim.api.nvim_get_current_buf()
  if vim.tbl_isempty(vim.lsp.get_clients({ bufnr = bufnr })) then
    return
  end

  local pos = vim.api.nvim_win_get_cursor(0)
  local line = vim.api.nvim_get_current_line()
  local line_to_cursor = line:sub(1, pos[2])

  -- Get the start position of the current keyword
  local textMatch = vim.fn.match(line_to_cursor, "\\k*$")

  local params = vim.lsp.util.make_position_params()

  local items = {}
  vim.lsp.buf_request(bufnr, "textDocument/completion", params, function(err, result, ctx)
    if err or not result or vim.fn.mode() ~= "i" then
      return
    end
    -- print("params "..vim.inspect(params)) -- TODO debug
    -- print("result "..vim.inspect(result)) -- TODO debug
    -- do -- TODO debug
    --   local fd = assert(vim.uv.fs_open("/var/tmp/textDocument_completion_result.lua", "w", 438))
    --   vim.uv.fs_write(fd, vim.inspect(result))
    --   assert(vim.uv.fs_close(fd))
    -- end

    -- Completion response items may be relative to a position different than `textMatch`.
    -- Concrete example, with sumneko/lua-language-server:
    --
    -- require('plenary.asy|
    --         ▲       ▲   ▲
    --         │       │   └── cursor_pos: 20
    --         │       └────── textMatch: 17
    --         └────────────── textEdit.range.start.character: 9
    --                                 .newText = 'plenary.async'
    --                  ^^^
    --                  prefix (We'd remove everything not starting with `asy`,
    --                  so we'd eliminate the `plenary.async` result
    --
    -- `adjust_start_col` is used to prefer the language server boundary.
    --
    local client = vim.lsp.get_client_by_id(ctx.client_id)
    local encoding = client and client.offset_encoding or "utf-16"
    local candidates = vim.lsp.util.extract_completion_items(result)
    local startbyte = adjust_start_col(pos[1], line, candidates, encoding) or textMatch
    local prefix = line:sub(startbyte + 1, pos[2])
    -- print("line "..vim.inspect(line)) -- TODO debug
    -- print(string.format("startbyte %s, pos[2] %s, prefix %s ", startbyte, pos[2], prefix)) -- TODO debug
    local matches

    if M.snippet_support(client) then
      matches = require("lbrayner.lsp.util").text_document_completion_list_to_complete_items(result, prefix)
    else
      matches = vim.lsp.util.text_document_completion_list_to_complete_items(result, prefix)
    end

    -- TODO(ashkan): is this the best way to do this?
    vim.list_extend(items, matches)
    vim.fn.complete(startbyte + 1, items)
  end)

  -- Return -2 to signal that we should continue completion so that we can
  -- async complete.
  return -2
end

function M.on_list(options)
  if #options.items > 1  then
    vim.fn.setqflist({}, " ", options)
    vim.cmd("botright copen")
    return
  end

  local qfitem = options.items[1]
  local filename = qfitem.filename
  local pos = { qfitem.lnum, (qfitem.col - 1) }

  -- From vim.lsp.util.show_document
  -- Push a new item into tagstack
  local from = { vim.fn.bufnr("%"), vim.fn.line("."), vim.fn.col("."), 0 }
  local items = { { tagname = vim.fn.expand("<cword>"), from = from } }
  vim.fn.settagstack(vim.fn.win_getid(), { items = items }, "t")

  require("lbrayner").jump_to_location(filename, pos)
end

function M.snippet_support(client)
  if not client then return end
  return vim.tbl_get(client.config.capabilities.textDocument, "completion", "completionItem", "snippetSupport")
end

return M
