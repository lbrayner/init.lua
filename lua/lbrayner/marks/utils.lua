-- Borrowed from marks.nvim (https://github.com/chentoast/marks.nvim)

local M = {}

local builtin_marks = { ["."] = true, ["^"] = true, ["`"] = true, ["'"] = true,
                        ['"'] = true, ["<"] = true, [">"] = true, ["["] = true,
                        ["]"] = true }
for i = 0,9 do
  builtin_marks[tostring(i)] = true
end

function M.is_valid_mark(char)
  return M.is_letter(char) or builtin_marks[char]
end

function M.is_letter(char)
  return M.is_upper(char) or M.is_lower(char)
end

function M.is_upper(char)
  return (65 <= char:byte() and char:byte() <= 90)
end

function M.is_lower(char)
  return (97 <= char:byte() and char:byte() <= 122)
end

return M
