return {
  get = function()
    return {
      command = {
        User1 = { fg = "Todo" },
        User2 = { fg = "Cursor" },
        User3 = { fg = "Underlined" },
        User4 = { fg = "Comment" },
        User5 = { fg = "Comment" },
        User6 = { fg = "Underlined" },
        StatusLine = { bg = "Constant", fg = "Cursor" },
      },
      insert = {
        User1 = { fg = "Todo" },
        User2 = { fg = "Cursor" },
        User3 = { fg = "Underlined" },
        User4 = { fg = "Special" },
        User5 = { fg = "Cursor" },
        User6 = { fg = "Comment" },
        StatusLine = { bg = "Added", fg = "Cursor" },
      },
      normal = {
        User1 = { fg = "Todo" },
        User2 = { fg = "Underlined" },
        User3 = { fg = "Special" },
        User4 = { fg = "Comment" },
        User5 = { fg = "Normal" },
        User6 = { fg = "Statement" },
        StatusLine = { bg = "NONE", fg = "Identifier" },
      },
      search = {
        User1 = { fg = "Include" },
        User2 = { fg = "Cursor" },
        User3 = { fg = "Special" },
        User4 = { fg = "Normal" },
        User5 = { fg = "Cursor" },
        User6 = { fg = "Special" },
        StatusLine = { bg = "Removed", fg = "Cursor" },
      },
      select = {
        User1 = { fg = "Include" },
        User2 = { fg = "Cursor" },
        User3 = { fg = "Special" },
        User4 = { fg = "Underlined" },
        User5 = { fg = "Cursor" },
        User6 = { fg = "Special" },
        StatusLine = { bg = "Type", fg = "Cursor" },
      },
      visual = {
        User1 = { fg = "Todo" },
        User2 = { fg = "Cursor" },
        User3 = { fg = "Special" },
        User4 = { fg = "Underlined" },
        User5 = { fg = "Cursor" },
        User6 = { fg = "Comment" },
        StatusLine = { bg = "Changed", fg = "Cursor" },
      },
      terminal = {
        StatusLine = { bg = "Statement" },
      },
    }
  end
}
