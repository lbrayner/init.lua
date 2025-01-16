local M = {}

local function replace_keyword_under_cursor(coerce)
  -- From $VIMRUNTIME/lua/vim/lsp/_completion.lua, vim.lsp._completion.omnifunc
  local winid = vim.api.nvim_get_current_win()
  local cursor = vim.api.nvim_win_get_cursor(winid)
  local lnum = cursor[1] - 1
  local line = vim.api.nvim_get_current_line()
  local line_to_cursor = line:sub(1, cursor[2])
  local keyword_start = vim.fn.match(line_to_cursor, "\\k*$")
  local cursor_til_end = line:sub(keyword_start + 1)
  local keyword_end = keyword_start + vim.fn.match(cursor_til_end, "[^[:keyword:]]")
  keyword_end = keyword_end < keyword_start and vim.fn.col("$") - 1 or keyword_end
  local bufnr = vim.api.nvim_win_get_buf(winid)
  local keyword = vim.api.nvim_buf_get_text(bufnr, lnum, keyword_start, lnum, keyword_end, {})[1]
  keyword = coerce(keyword)
  vim.api.nvim_buf_set_text(bufnr, lnum, keyword_start, lnum, keyword_end, { keyword })
end

-- Adding dot-repeat to your Neovim plugin
-- See https://gist.github.com/kylechui/a5c1258cd2d86755f97b10fc921315c3
local function make_operator(coerce)
  M.operatorfunc = function()
    replace_keyword_under_cursor(coerce)
  end
  vim.go.operatorfunc = "v:lua.require'lbrayner.coerce'.operatorfunc"
  return "g@l"
end

-- Coerce keyword to camelCase
vim.keymap.set("n", "crc", function()
  return make_operator(function(word)
    word = string.gsub(word, "-", "_")
    if not require("lbrayner").contains(word, "_") and string.find(word, "%l") then
      return string.gsub(word, "^.", string.lower)
    end
    -- From tpope's vim-abolish
    word = vim.fn.substitute(word, [[\C\(_\)\=\(.\)]],
    [[\=submatch(1)==""?tolower(submatch(2)) : toupper(submatch(2))]], "g")
    return word
  end)
end, { expr = true })

-- Coerce keyword to snake_case
vim.keymap.set("n", "cr_", function()
  return make_operator(function(word)
    -- From tpope's vim-abolish
    word = string.gsub(word, "::", "/")
    word = string.gsub(word, "(%u+)(%u%l)", "%1_%2")
    word = string.gsub(word, "([%l%d])(%u)", "%1_%2")
    word = string.gsub(word, "[.-]", "_")
    word = word:lower()
    return word
  end)
end, { expr = true })

return M
