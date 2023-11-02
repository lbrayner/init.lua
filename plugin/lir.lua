vim.g.loaded_netrwPlugin = 1

local actions = require("lir.actions")
local clipboard_actions = require("lir.clipboard.actions")
local mark_actions = require("lir.mark.actions")

require("lir").setup {
  show_hidden_files = false,
  devicons = {
    enable = true,
    highlight_dirname = true,
  },
  mappings = {
    ["l"]     = actions.edit,
    ["<C-s>"] = actions.split,
    ["<C-v>"] = actions.vsplit,
    ["<C-t>"] = actions.tabedit,

    ["h"]     = actions.up,
    ["q"]     = actions.quit,

    ["K"]     = actions.mkdir,
    ["N"]     = actions.newfile,
    ["R"]     = actions.rename,
    ["@"]     = actions.cd,
    ["Y"]     = actions.yank_path,
    ["."]     = actions.toggle_show_hidden,
    ["D"]     = actions.delete,

    ["J"] = function()
      mark_actions.toggle_mark()
      vim.cmd("normal! j")
    end,
    ["C"] = clipboard_actions.copy,
    ["X"] = clipboard_actions.cut,
    ["P"] = clipboard_actions.paste,
  },
  hide_cursor = true
}

vim.api.nvim_create_autocmd("FileType", {
  pattern = "lir",
  callback = function()
    -- use visual mode
    vim.api.nvim_buf_set_keymap(
    0,
    "x",
    "J",
    ":<C-u>lua require'lir.mark.actions'.toggle_mark('v')<CR>",
    { noremap = true, silent = true }
    )

    -- echo cwd
    vim.api.nvim_echo({ { vim.fn.expand("%:p"), "Normal" } }, false, {})
  end
})

vim.keymap.set("n", "g-", "<Cmd>e .<CR>") -- Open current directory
vim.keymap.set("n", "-", function() -- Open buffer's containing directory
  if require("lir.vim").get_context() then
    require("lir.actions").up()
    return
  end
  vim.cmd(string.format("e %s", vim.fn.fnameescape(vim.fn.expand("%:p:h"))))
end)
