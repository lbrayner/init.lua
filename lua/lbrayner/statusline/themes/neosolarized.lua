local mapping = {
  insert = {
    User1 = { bg = "Added", fg = "Todo" },
    User2 = { bg = "Added", fg = "Ignore" },
    User3 = { bg = "Added", fg = "Underlined" },
    User4 = { bg = "Added", fg = "Special" },
    User5 = { bg = "Added", fg = "Ignore" },
    User6 = { bg = "Added", fg = "Comment" },
    User7 = { bg = "Added" },
    User9 = { bg = "Added", fg = "Underlined" },
    StatusLine = { bg = "Added", fg = "Ignore" },
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
    User1 = { bg = "Special", fg = "Include" },
    User2 = { bg = "Special", fg = "Ignore" },
    User3 = { bg = "Special", fg = "Underlined" },
    User4 = { bg = "Special", fg = "Include" },
    User5 = { bg = "Special", fg = "Ignore" },
    User6 = { bg = "Special", fg = "Comment" },
    User7 = { bg = "Special" },
    User9 = { bg = "Special", fg = "Comment" },
    StatusLine = { bg = "Constant", fg = "Include" },
  },
  visual = {
    User1 = { bg = "Changed", fg = "Todo" },
    User2 = { bg = "Changed", fg = "Ignore" },
    User3 = { bg = "Changed", fg = "Todo" },
    User4 = { bg = "Changed", fg = "Underlined" },
    User5 = { bg = "Changed", fg = "Ignore" },
    User6 = { bg = "Changed", fg = "Comment" },
    User7 = { bg = "Changed" },
    User9 = { bg = "Changed", fg = "Special" },
    StatusLine = { bg = "Constant", fg = "Include" }
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
