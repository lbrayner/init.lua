local mapping = {
  command = {
    User1 = { bg = "Constant", fg = "Todo" },
    User2 = { bg = "Constant", fg = "Cursor" },
    User3 = { bg = "Constant", fg = "Todo" },
    User4 = { bg = "Constant", fg = "Comment" },
    User5 = { bg = "Constant", fg = "Comment" },
    User6 = { bg = "Constant", fg = "Underlined" },
    User7 = { bg = "Constant" },
    User9 = { bg = "Constant", fg = "Underlined" },
    StatusLine = { bg = "Constant", fg = "Cursor" },
  },
  insert = {
    User1 = { bg = "Added", fg = "Todo" },
    User2 = { bg = "Added", fg = "Cursor" },
    User3 = { bg = "Added", fg = "Underlined" },
    User4 = { bg = "Added", fg = "Special" },
    User5 = { bg = "Added", fg = "Cursor" },
    User6 = { bg = "Added", fg = "Comment" },
    User7 = { bg = "Added" },
    User9 = { bg = "Added", fg = "Underlined" },
    StatusLine = { bg = "Added", fg = "Cursor" },
  },
  normal = {
    User1 = { bg = "", fg = "Todo" },
    User2 = { bg = "", fg = "Underlined" },
    User3 = { bg = "", fg = "Todo" },
    User4 = { bg = "", fg = "Comment" },
    User5 = { bg = "", fg = "Ignore" },
    User6 = { bg = "", fg = "Statement" },
    User7 = { bg = "Cursor" },
    User9 = { bg = "", fg = "Special" },
    StatusLine = { bg = "", fg = "Identifier" },
  },
  search = {
    User1 = { bg = "Removed", fg = "Include" },
    User2 = { bg = "Removed", fg = "Cursor" },
    User3 = { bg = "Removed", fg = "Special" },
    User4 = { bg = "Removed", fg = "Normal" },
    User5 = { bg = "Removed", fg = "Cursor" },
    User6 = { bg = "Removed", fg = "Special" },
    User7 = { bg = "Removed" },
    User9 = { bg = "Removed", fg = "Special" },
    StatusLine = { bg = "Removed", fg = "Cursor" },
  },
  visual = {
    User1 = { bg = "Changed", fg = "Todo" },
    User2 = { bg = "Changed", fg = "Cursor" },
    User3 = { bg = "Changed", fg = "Todo" },
    User4 = { bg = "Changed", fg = "Underlined" },
    User5 = { bg = "Changed", fg = "Cursor" },
    User6 = { bg = "Changed", fg = "Comment" },
    User7 = { bg = "Changed" },
    User9 = { bg = "Changed", fg = "Special" },
    StatusLine = { bg = "Changed", fg = "Cursor" },
  },
  terminal = {
    StatusLine = { bg = "Statement" },
  },
}

return {
  get_color_mapping = function()
    return vim.deepcopy(mapping)
  end,
}
