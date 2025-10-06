-- fzf-lua

local keymap = require("lz.n").keymap({
  "fzf-lua",
  after = function()
    require("lbrayner.setup.fzf-lua")
  end,
})

local opts = { silent = true }

keymap.set("n", "<F1>", function()
  require("lbrayner.fzf-lua").help_tags()
end, opts)
keymap.set("n", "<F4>", function()
  require("lbrayner.fzf-lua").file_marks()
end, opts)
keymap.set("n", "<F5>", function()
  require("lbrayner.fzf-lua").buffers()
end, opts)
keymap.set("n", "<F7>", function()
  require("lbrayner.fzf-lua").files()
end, opts)
keymap.set("n", "<F8>", function()
  require("lbrayner.fzf-lua").tabs()
end, opts)

-- nvim-dap-ui

require("lz.n").load({
  "nvim-dap-ui",
  after = function()
    require("lbrayner.dapui").create_user_commands()
    require("dapui").setup()
    require("dap").defaults.fallback.terminal_win_cmd = require("lbrayner.jdtls.dap").terminal_win_cmd
  end,
  cmd = "DapUiToggle",
})
