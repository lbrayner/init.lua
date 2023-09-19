vim.go.backspace =  "indent,eol,start"
vim.go.backupcopy = "yes" -- So that watchprocesses work as expected
vim.go.completeopt = "menuone"
vim.go.fileformats = "unix,dos"
vim.go.ignorecase = true
vim.go.lazyredraw = true
vim.go.listchars = "eol:¬,tab:» ,trail:·"
vim.go.ruler = false
vim.go.showmode = false
vim.go.smartcase = true
vim.go.splitbelow = true
vim.go.splitright = true
vim.go.switchbuf = "usetab,uselast"
vim.go.title = true
vim.go.wildmenu = true
vim.go.wildmode = "longest:full"

vim.bo.expandtab = true
vim.bo.fileformat = "unix"
vim.bo.shiftwidth = 2 -- when indenting with '>', use 2 spaces width
vim.bo.synmaxcol = 500 -- From tpope's vim-sensible (lowering this improves performance in files with long lines)
vim.bo.tabstop = 4 -- show existing tab with 4 spaces width

vim.wo.breakindent = true
vim.wo.cursorline = true
vim.wo.linebreak = true
vim.wo.number = true
vim.wo.relativenumber = true
