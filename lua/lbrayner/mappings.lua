-- disable Ex mode mapping
vim.keymap.set("n", "Q", "<Nop>", { remap = true })

-- cedilla is right where : is on an en-US keyboard
vim.keymap.set("n", "ç", ":")
vim.keymap.set("v", "ç", ":")
vim.keymap.set("n", "Ç", ":<Up><CR>")
vim.keymap.set("v", "Ç", ":<Up><CR>")
vim.keymap.set("n", "¬", "^")
vim.keymap.set("n", "qç", "q:")
vim.keymap.set("v", "qç", "q:")
vim.keymap.set("v", "¬", "^")

-- alternate file
vim.keymap.set("n", "<Space>a", "<Cmd>b#<CR>")

-- clear search highlights
vim.keymap.set("n", "<F2>", "<Cmd>set invhlsearch hlsearch?<CR>", { silent = true })

-- easier window switching
vim.keymap.set("n", "<C-H>", "<Cmd>wincmd h<CR>")
vim.keymap.set("n", "<C-J>", "<Cmd>wincmd j<CR>")
vim.keymap.set("n", "<C-K>", "<Cmd>wincmd k<CR>")
vim.keymap.set("n", "<C-L>", "<Cmd>wincmd l<CR>")

-- write
vim.keymap.set({ "n", "v" }, "<F6>", "<Cmd>w<CR>")
vim.keymap.set("i", "<F6>", "<Esc><Cmd>w<CR>")

-- list mode
vim.keymap.set({
  "", -- nvo: normal, visual, operator-pending
  "i" }, "<F12>", "<Cmd>set list!<CR>", { silent = true })

-- quickfix and locallist
vim.keymap.set("n", "<Space>l", "<Cmd>lopen<CR>", { silent = true })
vim.keymap.set("n", "<Space>q", "<Cmd>botright copen<CR>", { silent = true })

-- Close preview window
vim.keymap.set("n", "<Space>p", "<Cmd>pclose<CR>", { silent = true })

-- force case sensitivity for *-search
vim.keymap.set("n", "*", [[/\C\V\<<C-R><C-W>\><CR>]])

-- Neovim terminal
-- Case matters for keys after alt or meta
vim.keymap.set("t", "<A-h>", [[<C-\><C-N><C-W>h]])
vim.keymap.set("t", "<A-j>", [[<C-\><C-N><C-W>j]])
vim.keymap.set("t", "<A-k>", [[<C-\><C-N><C-W>k]])
vim.keymap.set("t", "<A-l>", [[<C-\><C-N><C-W>l]])

-- Command line

-- Emacs-style editing in command-line mode and insert mode
-- Case matters for keys after alt or meta

-- Return to Normal mode
vim.keymap.set("c", "<C-G>", "<C-C>")

-- kill line
vim.keymap.set("c", "<C-K>", "<C-F>D<C-C><Right>")
vim.keymap.set("i", "<C-K>", "<C-O>D")

-- Insert digraph
vim.keymap.set({ "c", "i" }, "<C-X>8", "<C-K>")

-- inserting the current line
vim.keymap.set("c", "<C-R><C-L>", [[<C-R>=getline(".")<CR>]])
-- inserting the current line number
vim.keymap.set("c", "<C-R><C-N>", [[<C-R>=line(".")<CR>]])

-- Insert timestamps
vim.keymap.set("i", "<F3>", [[<C-R>=strftime("%Y-%m-%d %a %0H:%M")<CR>]])

-- Rename word
vim.keymap.set("n", "<Leader>a", [[:keepp %s/\C\V\<<C-R><C-W>\>//gc<Left><Left><Left>]])
vim.keymap.set("n", "<Leader>x", [[:keepp .,$s/\C\V\<<C-R><C-W>\>//gc<Left><Left><Left>]])
-- Rename visual selection
vim.keymap.set("v", "<Leader>a", [[""y:keepp %s/\C\V<C-R>"//gc<Left><Left><Left>]])
vim.keymap.set("v", "<Leader>x", [[""y:keepp .,$s/\C\V<C-R>"//gc<Left><Left><Left>]])

-- From vim-unimpaired: insert blank lines above and below
vim.keymap.set("n", "[<Space>", [[<Cmd>exe "put!=repeat(nr2char(10), v:count1)\<Bar>silent ']+"<CR>]])
vim.keymap.set("n", "]<Space>", [[<Cmd>exe "put =repeat(nr2char(10), v:count1)\<Bar>silent ']-"<CR>]])

-- nvim-spider

if pcall(require, "spider") then
  local function spider(motion)
    return function() require("spider").motion(motion) end
  end

  vim.keymap.set({"n", "o", "x"}, "<Leader>w",  spider("w"),  { desc = "Spider-w"  })
  vim.keymap.set({"n", "o", "x"}, "<Leader>e",  spider("e"),  { desc = "Spider-e"  })
  vim.keymap.set({"n", "o", "x"}, "<Leader>b",  spider("b"),  { desc = "Spider-b"  })
  vim.keymap.set({"n", "o", "x"}, "<Leader>ge", spider("ge"), { desc = "Spider-ge" })
end
