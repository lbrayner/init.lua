local function display_error(swb)
  local command = "cc"
  if vim.fn.getwininfo(vim.api.nvim_get_current_win())[1].loclist == 1 then
    command = "ll"
  end
  local switchbuf = vim.go.switchbuf
  vim.go.switchbuf = swb
  local linenr = vim.api.nvim_win_get_cursor(0)[1]
  vim.cmd.wincmd("p") -- TODO to avoid https://github.com/vim/vim/issues/12436
  vim.cmd(linenr .. command)
  vim.go.switchbuf = switchbuf
end

local function split_open()       display_error("usetab,split")  end
local function tab_open()         display_error("usetab,newtab") end
local function vsplit_open()      display_error("usetab,vsplit") end

local qf_setup = vim.api.nvim_create_augroup("qf_setup", { clear=true })

vim.api.nvim_create_autocmd("FileType", {
  group = qf_setup,
  desc = "Quickfix setup",
  pattern = "qf",
  callback = function(args)
    local bufnr = args.buf
    local wininfos = vim.tbl_filter(function(wininfo)
      return wininfo.bufnr == bufnr
    end, vim.fn.getwininfo())

    for _, wininfo in ipairs(wininfos) do
      local winid = wininfo.winid

      vim.wo[winid].spell = false
      vim.wo[winid].wrap = false

      vim.keymap.set("n", "o", split_open, { buffer = bufnr })
      vim.keymap.set("n", "O", vsplit_open, { buffer = bufnr })
      vim.keymap.set("n", "<Tab>", tab_open, { buffer = bufnr })

      vim.keymap.set("n", "q", function()
        vim.api.nvim_win_close(0, false)
      end, { buffer = bufnr, nowait = true })
    end
  end,
})
