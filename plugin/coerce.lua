-- Coerce to camelCase
vim.keymap.set("n", "crc", function()
  -- From $VIMRUNTIME/lua/vim/lsp/_completion.lua, vim.lsp._completion.omnifunc
  local win = vim.api.nvim_get_current_win()
  local cursor = vim.api.nvim_win_get_cursor(win)
  local lnum = cursor[1] - 1
  local line = vim.api.nvim_get_current_line()
  local line_to_cursor = line:sub(1, cursor[2])
  local cword_start = vim.fn.match(line_to_cursor, "\\k*$")
  local cursor_til_end = line:sub(cword_start + 1)
  local cword_end = cword_start + vim.fn.match(cursor_til_end, "[^[:keyword:]]") - 1
  cword_end = cword_end < cword_start and vim.fn.col("$") - 1 or cword_end
  local bufnr = vim.api.nvim_win_get_buf(win)
  local word = vim.api.nvim_buf_get_text(bufnr, lnum, cword_start, lnum, cword_end, {})[1]
  word = string.gsub(word, "-", "_")
  -- From tpope's vim-abolish
  word = vim.fn.substitute(word, [[\C\(_\)\=\(.\)]],
  [[\=submatch(1)==""?tolower(submatch(2)) : toupper(submatch(2))]], "g")
  vim.api.nvim_buf_set_text(bufnr, lnum, cword_start, lnum, cword_end, { word })
end)

-- Convert from camelCase to score_case
vim.keymap.set("n", "cr_", [[:keepp s#\(\<\u\l\+\|\l\+\)\(\u\)#\l\1_\l\2#g]])
