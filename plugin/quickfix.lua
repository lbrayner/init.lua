local function display_error_switchbuf(swb)
  local command = "cc"
  if require("lbrayner").is_location_list() then
    command = "ll"
  end
  local switchbuf = vim.go.switchbuf
  vim.go.switchbuf = swb
  local linenr = vim.api.nvim_win_get_cursor(0)[1]
  vim.cmd.wincmd("p") -- TODO to avoid https://github.com/vim/vim/issues/12436
  vim.cmd(linenr .. command)
  vim.go.switchbuf = switchbuf
end

local function display_error_cmd(cmd)
  local command = "cc"
  if require("lbrayner").is_location_list() then
    command = "ll"
  end
  local linenr = vim.api.nvim_win_get_cursor(0)[1]
  vim.cmd.wincmd("p")
  vim.cmd(cmd)
  vim.cmd(linenr .. command)
end

local qf_setup = vim.api.nvim_create_augroup("qf_setup", { clear = true })

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

      vim.keymap.set("n", "o", function()
        display_error_switchbuf("usetab,split")
      end, { buffer = bufnr })
      vim.keymap.set("n", "O", function()
        display_error_switchbuf("usetab,vsplit")
      end, { buffer = bufnr })
      vim.keymap.set("n", "<Tab>", function()
        display_error_switchbuf("usetab,newtab")
      end, { buffer = bufnr })

      vim.keymap.set("n", "<Leader>o", function()
        display_error_cmd("split")
      end, { buffer = bufnr })
      vim.keymap.set("n", "<Leader>O", function()
        display_error_cmd("vsplit")
      end, { buffer = bufnr })
      vim.keymap.set("n", "<Leader><Tab>", function()
        display_error_cmd("tabnew")
      end, { buffer = bufnr })

      vim.keymap.set("n", "q", function()
        vim.api.nvim_win_close(0, false)
      end, { buffer = bufnr, nowait = true })
    end

    local function get_name_by_bufnr()
      local name_by_bufnr = vim.empty_dict()
      for _, qfitem in ipairs(vim.fn.getqflist()) do
        if not name_by_bufnr[qfitem.bufnr] then
          name_by_bufnr[qfitem.bufnr] = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(qfitem.bufnr), ":~")
        end
      end
      return name_by_bufnr
    end

    -- https://github.com/wincent/ferret: ferret#private#qargs()
    if require("lbrayner").is_quickfix_list() then
      vim.api.nvim_buf_create_user_command(bufnr, "QFFileNamesToArgList", function()
        local name_by_bufnr = get_name_by_bufnr()
        local names = vim.tbl_map(function(name)
          return vim.fn.fnameescape(name)
        end, vim.tbl_values(name_by_bufnr))
        vim.cmd("%argdelete")
        vim.cmd.argadd(table.concat(names, " "))
      end, { nargs = 0 })
      vim.api.nvim_buf_create_user_command(bufnr, "QFYankFileNames", function()
        local name_by_bufnr = get_name_by_bufnr()
        local names = vim.tbl_values(name_by_bufnr)
        vim.fn.setreg('"', names)
        vim.fn.setreg("+", names)
        vim.fn.setreg("*", names)
      end, { nargs = 0 })
    end
  end,
})
