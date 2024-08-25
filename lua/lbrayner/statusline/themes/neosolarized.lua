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
    User1 = { fg = "Todo" },
    User2 = { fg = "Underlined" },
    User3 = { fg = "Todo" },
    User4 = { fg = "Comment" },
    User5 = { fg = "Ignore" },
    User6 = { fg = "Statement" },
    User9 = { fg = "Special" },
    StatusLine = { fg = "Identifier" },
  },
  search = {
    User1 = { bg = "Underlined", fg = "Include" },
    User2 = { bg = "Underlined", fg = "Cursor" },
    User3 = { bg = "Underlined", fg = "Special" },
    User4 = { bg = "Underlined", fg = "Normal" },
    User5 = { bg = "Underlined", fg = "Cursor" },
    User6 = { bg = "Underlined", fg = "Special" },
    User7 = { bg = "Underlined" },
    User9 = { bg = "Underlined", fg = "Special" },
    StatusLine = { bg = "Underlined", fg = "Cursor" },
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
  get_attr_map = function()
    return {
      normal = { bold = true },
      visual = { bold = true },
      insert = { bold = true },
      command = { bold = true },
      terminal = { bold = true },
      search = { bold = true },
    }
  end,
  get_color_mapping = function()
    return vim.deepcopy(mapping)
  end,
}
