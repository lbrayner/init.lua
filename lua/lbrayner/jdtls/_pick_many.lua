require("jdtls.ui").pick_many = function(items)
  print("slim shady", vim.inspect(items))
  return require("fzf-lua").fzf_exec(items, { prompt = "Projects> " })
end
