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

require("mini.jump").setup({
  mappings = {
    repeat_jump = "",
  },
})

local function save_to_jumplist_wrap(jump)
  if vim.bo.buftype ~= "terminal" then -- TODO debug to find the real cause
    vim.cmd("normal! m'")
  end
  jump()
end

vim.keymap.set("n", ";", function()
  save_to_jumplist_wrap(function()
    MiniJump.jump(nil, false)
  end)
end)
vim.keymap.set("n", ",", function()
  save_to_jumplist_wrap(function()
    MiniJump.jump(nil, true)
  end)
end)

--
-- mini.files
--

vim.g.loaded_netrwPlugin = true

require("mini.files").setup({
  -- Module mappings created only inside explorer.
  -- Use `""` (empty string) to not create one.
  mappings = {
    go_in_plus  = "",
    go_out_plus = "",
  },
})

local files_set_cwd = function(path)
  -- Works only if cursor is on the valid file system entry
  local cur_entry_path = MiniFiles.get_fs_entry().path
  local cur_directory = vim.fs.dirname(cur_entry_path)
  vim.fn.chdir(cur_directory)
end

local mini_files_custom = vim.api.nvim_create_augroup("mini_files_custom", { clear = true })

vim.api.nvim_create_autocmd("User", {
  group = mini_files_custom,
  desc = "Custom mini.files mappings",
  pattern = "MiniFilesBufferCreate",
  callback = function(args)
    vim.keymap.set("n", "g~", files_set_cwd, { buffer = args.data.buf_id })
  end,
})

vim.keymap.set("n", "g-", MiniFiles.open)
vim.keymap.set("n", "-", function()
  MiniFiles.open(vim.api.nvim_buf_get_name(0), false)
end)

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
