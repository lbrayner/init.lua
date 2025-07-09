local function table_find_index_eq(table, value)
  for i, t in ipairs(table) do
    if t == value then
      return i
    end
  end
end

vim.api.nvim_create_user_command("TabcloseRange", function(opts)
  local from, to = unpack(vim.tbl_map(function(arg)
    return tonumber(arg)
  end, opts.fargs))
  local tabs_to_close = {}
  local tabn = from
  while tabn <= #vim.api.nvim_list_tabpages() and tabn <= to do
    table.insert(tabs_to_close, vim.api.nvim_list_tabpages()[tabn])
    tabn = tabn + 1
  end
  local ei = vim.o.eventignore
  vim.opt.eventignore:append({ "TabClosed" })
  while not vim.tbl_isempty(tabs_to_close) do
    local tabh = table.remove(tabs_to_close, 1)
    local tabnr = table_find_index_eq(vim.api.nvim_list_tabpages(), tabh)
    vim.cmd(tabnr .. "tabclose" .. (opts.bang and "!" or ""))
  end
  vim.o.eventignore = ei
end, { bang = true, nargs = "+" })

vim.api.nvim_create_user_command("TabcloseRight", function(opts)
  local current_tab = vim.fn.tabpagenr()
  local ei = vim.o.eventignore
  vim.opt.eventignore:append({ "TabClosed" })
  while current_tab < vim.fn.tabpagenr("$") do
    vim.cmd((current_tab + 1) .. "tabclose" .. (opts.bang and "!" or ""))
  end
  vim.o.eventignore = ei
end, { bang = true, nargs = 0 })

vim.api.nvim_create_user_command("TabcloseLeft", function(opts)
  local ei = vim.o.eventignore
  vim.opt.eventignore:append({ "TabClosed" })
  while vim.fn.tabpagenr() > 1 do
    vim.cmd("1tabclose" .. (opts.bang and "!" or ""))
  end
  vim.o.eventignore = ei
end, { bang = true, nargs = 0 })

vim.api.nvim_create_user_command("Tabonly", function(opts)
  local ei = vim.o.eventignore
  vim.opt.eventignore:append({ "TabClosed" })
  vim.cmd("tabonly" .. (opts.bang and "!" or ""))
  vim.o.eventignore = ei
end, { bang = true, nargs = 0 })

vim.api.nvim_create_user_command("Tabclose", function(opts)
  local ei = vim.o.eventignore
  vim.opt.eventignore:append({ "TabClosed" })
  local tc = vim.o.tabclose
  vim.o.tabclose = ""
  vim.cmd.tabclose()
  vim.o.eventignore = ei
  vim.o.tabclose = tc
end, { bang = true, nargs = 0 })

vim.api.nvim_create_user_command("TabeditThis", function(opts)
  require("lbrayner").preserve_view_port(function()
    if opts.range == 1 and opts.count == math.max(
      1,
      vim.api.nvim_win_get_cursor(0)[1] - 1
    ) then
      -- Supplied range was "-"
      vim.cmd("-tab split")
    else
      vim.cmd("tab split")
    end
  end)
end, { nargs = 0, range = true })
