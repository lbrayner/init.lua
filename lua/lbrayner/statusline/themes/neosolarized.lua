return {
  get_color_mapping = function()
    return {
      command = {
        User1 = { bg = "Constant", fg = "Todo" },
        User2 = { bg = "Constant", fg = "Cursor" },
        User3 = { bg = "Constant", fg = "Underlined" },
        User4 = { bg = "Constant", fg = "Comment" },
        User5 = { bg = "Constant", fg = "Comment" },
        User6 = { bg = "Constant", fg = "Underlined" },
        StatusLine = { bg = "Constant", fg = "Cursor" },
      },
      insert = {
        User1 = { bg = "Added", fg = "Todo" },
        User2 = { bg = "Added", fg = "Cursor" },
        User3 = { bg = "Added", fg = "Underlined" },
        User4 = { bg = "Added", fg = "Special" },
        User5 = { bg = "Added", fg = "Cursor" },
        User6 = { bg = "Added", fg = "Comment" },
        StatusLine = { bg = "Added", fg = "Cursor" },
      },
      normal = {
        User1 = { bg = "NONE", fg = "Todo" },
        User2 = { bg = "NONE", fg = "Underlined" },
        User3 = { bg = "NONE", fg = "Special" },
        User4 = { bg = "NONE", fg = "Comment" },
        User5 = { bg = "NONE", fg = "Normal" },
        User6 = { bg = "NONE", fg = "Statement" },
        StatusLine = { bg = "NONE", fg = "Identifier" },
      },
      search = {
        User1 = { bg = "Removed", fg = "Include" },
        User2 = { bg = "Removed", fg = "Cursor" },
        User3 = { bg = "Removed", fg = "Special" },
        User4 = { bg = "Removed", fg = "Normal" },
        User5 = { bg = "Removed", fg = "Cursor" },
        User6 = { bg = "Removed", fg = "Special" },
        StatusLine = { bg = "Removed", fg = "Cursor" },
      },
      select = {
        User1 = { bg = "Type", fg = "Include" },
        User2 = { bg = "Type", fg = "Cursor" },
        User3 = { bg = "Type", fg = "Special" },
        User4 = { bg = "Type", fg = "Underlined" },
        User5 = { bg = "Type", fg = "Cursor" },
        User6 = { bg = "Type", fg = "Special" },
        StatusLine = { bg = "Type", fg = "Cursor" },
      },
      visual = {
        User1 = { bg = "Changed", fg = "Todo" },
        User2 = { bg = "Changed", fg = "Cursor" },
        User3 = { bg = "Changed", fg = "Special" },
        User4 = { bg = "Changed", fg = "Underlined" },
        User5 = { bg = "Changed", fg = "Cursor" },
        User6 = { bg = "Changed", fg = "Comment" },
        StatusLine = { bg = "Changed", fg = "Cursor" },
      },
      terminal = {
        StatusLine = { bg = "Statement" },
      },
    }
  end,
}
