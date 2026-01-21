-- vim: fdm=marker

vim.g.loaded_netrwPlugin = 1

local actions = require("lir.actions")
local clipboard_actions = require("lir.clipboard.actions")
local concat = table.concat
local get_context = require("lir.vim").get_context
local mark_actions = require("lir.mark.actions")

local function jump(vicmd) -- {{{
  return function()
    local ctx = get_context()
    local filename = vim.fn.fnameescape(concat({ ctx.dir, ctx:current_value() }))
    local bufnr = vim.fn.bufadd(filename)
    require("lbrayner").jump_to_location(bufnr, nil, { open_cmd = vicmd })
  end
end -- }}}

require("lir").setup {
  show_hidden_files = false,
  devicons = {
    enable = true,
    highlight_dirname = true,
  },
  mappings = {
    ["l"]     = actions.edit,
    ["<CR>"]  = jump(),
    ["o"]     = jump("new"),
    ["O"]     = jump("vnew"),
    ["<Tab>"] = jump("tabnew"),

    ["h"]     = actions.up,
    ["q"]     = actions.quit,

    ["K"]     = actions.mkdir,
    ["N"]     = actions.newfile,
    ["R"]     = actions.rename,
    ["@"]     = actions.cd,
    ["Y"]     = actions.yank_path,
    ["."]     = actions.toggle_show_hidden,
    ["D"]     = actions.delete,

    ["C"] = clipboard_actions.copy,
    ["X"] = clipboard_actions.cut,
    ["P"] = clipboard_actions.paste,

    ["J"] = function()
      mark_actions.toggle_mark()
      vim.cmd("normal! j")
    end,
    ["g~"] = function()
      vim.cmd.tcd("%")
    end
  },
  hide_cursor = true
}

local lir_custom = vim.api.nvim_create_augroup("lir_custom", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "lir",
  group = lir_custom,
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

local function open_cwd()
  -- :~ does not add a / at the end
  vim.cmd.edit(vim.fn.fnamemodify(".", ":~"))
end

vim.keymap.set("n", "-", function()
  if require("lir.vim").get_context() then
    require("lir.actions").up()
    return
  end
  local filename = vim.fn.expand("%:~:h")
  if filename == "" then
    open_cwd()
    return
  end
  vim.cmd.edit(filename)
end)
vim.keymap.set("n", "g-", open_cwd)
