--
-- mini.align
--

require("mini.align").setup()

--
-- mini.bracketed
--

require("mini.bracketed").setup({
  comment = { suffix = "n" },
  diagnostic = { suffix = "" },
  indent = { suffix = "" },
})

--
-- mini.comment
--

require("mini.comment").setup({
  mappings = {
    comment = "",
    comment_line = "",
    textobject = "",
  }
})

function MiniComment.comment_visual()
  if not vim.bo.modifiable then
    vim.fn.feedkeys("dd") -- So that E21 is thrown
    return
  end
  MiniComment.operator("visual")
end

vim.keymap.set("n", "gc", function()
  if not vim.bo.modifiable then return "d" end -- So that E21 is thrown
  return MiniComment.operator()
end, { expr = true, desc = "Comment" })
vim.keymap.set("x", "gc", [[:<C-U>lua MiniComment.comment_visual()<CR>]], { desc = "Comment selection" })
vim.keymap.set("n", "gcc", function()
  if not vim.bo.modifiable then return "d_" end -- So that E21 is thrown
  return MiniComment.operator() .. "_"
end, { expr = true, desc = "Comment line" })
vim.keymap.set("o", "gc", function()
  if not vim.bo.modifiable then return ".d" end -- So that E21 is thrown
  MiniComment.textobject()
end, { expr = true, desc = "Comment textobject" })

--
-- mini.indentscope
--

require("mini.indentscope").setup()

--
-- mini.jump
--

require("mini.jump").setup()

--
-- mini.move
--

require("mini.move").setup()

--
-- mini.pairs
--

require("mini.pairs").setup()

--
-- mini.surround
--

require("mini.surround").setup({
  mappings = {
    add = "ys",
    delete = "ds",
    find = "ysf", -- Find surrounding (to the right)
    find_left = "ysF", -- Find surrounding (to the left)
    highlight = "ysh", -- Highlight surrounding
    replace = "cs", -- Replace surrounding
    update_n_lines = "ysn", -- Update `n_lines`
  },
})

vim.keymap.del("x", "ys")
vim.keymap.set("x", "S", [[:<C-u>lua MiniSurround.add("visual")<CR>]], { desc = "Add surrounding to selection" })
