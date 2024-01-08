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
    ["<CR>"]  = actions.edit,
    ["o"]     = actions.split,
    ["O"]     = actions.vsplit,
    ["<Tab>"] = actions.tabedit,

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

local lir = vim.api.nvim_create_augroup("lir", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "lir",
  group = lir,
  callback = function()
    -- use visual mode
    vim.api.nvim_buf_set_keymap(
    0,
    "x",
    "J",
    ":<C-u>lua require'lir.mark.actions'.toggle_mark('v')<CR>",
    { noremap = true, silent = true }
    )
  end
})

-- :~ does not add a / at the end
local function open_cwd()
  vim.cmd(string.format("e %s", vim.fn.fnameescape(vim.fn.fnamemodify(".", ":~"))))
end

local function open_containing_dir()
  if require("lir.vim").get_context() then
    require("lir.actions").up()
    return
  end
  local filename = vim.fn.expand("%:~:h")
  if filename == "" then
    open_cwd()
    return
  end
  vim.cmd(string.format("e %s", vim.fn.fnameescape(filename)))
end

vim.keymap.set("n", "-", open_containing_dir)
vim.keymap.set("n", "g-", open_cwd)
