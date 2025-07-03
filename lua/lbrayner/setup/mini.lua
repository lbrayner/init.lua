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
    comment_visual = "",
    textobject = "",
  }
})

local function comment_operator()
  if not vim.bo.modifiable then return "d" end -- So that E21 is thrown
  return MiniComment.operator()
end

vim.keymap.set("n", "gc", comment_operator, { expr = true, desc = "Comment" })
vim.keymap.set("x", "gc", comment_operator, { expr = true, desc = "Comment selection" })
vim.keymap.set("n", "gcc", function()
  if not vim.bo.modifiable then return "d_" end -- So that E21 is thrown
  return MiniComment.operator() .. "_"
end, { expr = true, desc = "Comment line" })
vim.keymap.set("o", "gc", function()
  if not vim.bo.modifiable then return "ip" end -- So that E21 is thrown
  return "<Cmd>lua MiniComment.textobject()<CR>"
end, { expr = true, desc = "Comment textobject" })

--
-- mini.indentscope
--

require("mini.indentscope").setup({
  draw = {
    predicate = function(scope)
      if vim.wo.list then
        return false
      end

      return not scope.body.is_incomplete
    end,
  },
})

local indentscope = vim.api.nvim_create_augroup("indentscope", { clear = true })

vim.api.nvim_create_autocmd("OptionSet", {
  pattern = "list",
  group = indentscope,
  desc = "MiniIndentscope undraw if 'list' is set",
  callback = function()
    if not MiniIndentscope then return end

    if vim.v.option_new then
      MiniIndentscope.undraw()
    else
      MiniIndentscope.draw()
    end
  end,
})

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
