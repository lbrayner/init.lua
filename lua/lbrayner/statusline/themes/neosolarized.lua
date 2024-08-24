local mapping = {
  insert = {
    StatusLine = { bg = "Added", fg = "Ignore" },
    User1 = { bg = "Added", fg = "Todo" },
    User2 = { bg = "Added", fg = "Ignore" },
    User3 = { bg = "Added", fg = "Underlined" },
    User4 = { bg = "Added", fg = "Special" },
    User5 = { bg = "Added", fg = "Ignore" },
    User6 = { bg = "Added", fg = "Comment" },
    User9 = { bg = "Added", fg = "Underlined" },
  },
  normal = {
    StatusLine = { fg = "Identifier" },
    User1 = { fg = "Todo" },
    User2 = { fg = "Underlined" },
    User3 = { fg = "Todo" },
    User4 = { fg = "Comment" },
    User5 = { fg = "Ignore" },
    User6 = { fg = "Statement" },
    User9 = { fg = "Special" },
  },
  search = {
    StatusLine = { bg = "Constant", fg = "Include" },
  },
  visual = {
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
