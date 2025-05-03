require("jdtls.ui").pick_many = function(items)
  print("slim shady", vim.inspect(items))
  return items[1]
end
