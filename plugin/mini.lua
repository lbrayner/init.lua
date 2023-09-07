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

require("mini.comment").setup()

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

vim.keymap.set("n", ";", function()
  MiniJump.jump(nil, false)
end)
vim.keymap.set("n", ",", function()
  MiniJump.jump(nil, true)
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
