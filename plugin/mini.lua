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
