-- From :h qf.vim:

-- The quickfix filetype plugin includes configuration for displaying the command
-- that produced the quickfix list in the status-line. To disable this setting,
-- configure as follows:

vim.g.qf_disable_statusline = 1

vim.go.laststatus = 3
vim.go.statusline = "%{v:lua.require'lbrayner.statusline'.empty()}"
vim.go.winbar = "%{%v:lua.require'lbrayner.statusline'.winbar()%}"

local statusline = vim.api.nvim_create_augroup("statusline", { clear = true })

vim.api.nvim_create_autocmd("CmdlineEnter", {
  pattern = { ":", "/", "?" },
  group = statusline,
  callback = function(args)
    if args.file == ":" then
      require("lbrayner.statusline").highlight_mode("command")
    elseif vim.tbl_contains({ "/", "?" }, args.file) then
      require("lbrayner.statusline").highlight_mode("search")
    else
      return
    end
    vim.cmd.redraw() -- TODO redrawstatus should work here, create an issue on github
  end,
})

vim.api.nvim_create_autocmd("ColorScheme", {
  group = statusline,
  callback = require("lbrayner.statusline").initialize,
})

vim.api.nvim_create_autocmd("DiagnosticChanged", {
  group = statusline,
  callback = function()
    require("lbrayner.statusline").highlight_diagnostics() -- Not sending autocmd args as argument
  end,
})

vim.api.nvim_create_autocmd("InsertEnter", {
  group = statusline,
  callback = function()
    require("lbrayner.statusline").highlight_mode("insert")
    require("lbrayner.statusline").redefine_status_line()
  end,
})

vim.api.nvim_create_autocmd("ModeChanged", {
  pattern = [[[^vV\x16]:[vV\x16]*]],
  group = statusline,
  callback = function()
    require("lbrayner.statusline").highlight_mode("visual")
  end,
})

vim.api.nvim_create_autocmd("ModeChanged", {
  pattern = "[^n]*:n*",
  group = statusline,
  callback = function()
    require("lbrayner.statusline").highlight_mode("normal")
  end,
})

vim.api.nvim_create_autocmd("TermEnter", {
  group = statusline,
  callback = function()
    require("lbrayner.statusline").highlight_mode("terminal")
    require("lbrayner.statusline").define_terminal_status_line()
  end,
})

vim.api.nvim_create_autocmd("TermLeave", {
  group = statusline,
  callback = require("lbrayner.statusline").redefine_status_line,
})

vim.api.nvim_create_autocmd("User", {
  pattern = "CustomStatusline",
  group = statusline,
  callback = require("lbrayner.statusline").redefine_status_line,
})

vim.api.nvim_create_autocmd("VimEnter", {
  group = statusline,
  callback = function()
    vim.api.nvim_create_autocmd({ "BufWinEnter", "BufWritePost", "TextChanged", "TextChangedI", "WinEnter" }, {
      group = statusline,
      callback = vim.schedule_wrap(require("lbrayner.statusline").redefine_status_line),
    })
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  group = statusline,
  callback = vim.schedule_wrap(require("lbrayner.statusline").redefine_status_line),
})

if vim.v.vim_did_enter == 1 then
  vim.api.nvim_exec_autocmds("VimEnter", { group = statusline })
end

require("lbrayner.statusline").initialize()
