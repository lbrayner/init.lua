local mapping = {
  insert = {
    StatusLine = { bg = "Added", fg = "Ignore" },
  },
  normal = {
    StatusLine = { fg = "Identifier" },
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
