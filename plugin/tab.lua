local function table_find_index_eq(table, value)
  for i, t in ipairs(table) do
    if t == value then
      return i
    end
  end
end

vim.api.nvim_create_user_command("TabcloseRange", function(command)
  local from, to = unpack(vim.tbl_map(function(arg)
    return tonumber(arg)
  end, command.fargs))
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
    vim.cmd(tabnr .. "tabclose" .. (command.bang and "!" or ""))
  end
  vim.o.eventignore = ei
end, { bang = true, nargs = "+" })

vim.api.nvim_create_user_command("TabcloseRight", function(command)
  local current_tab = vim.fn.tabpagenr()
  local ei = vim.o.eventignore
  vim.opt.eventignore:append({ "TabClosed" })
  while current_tab < vim.fn.tabpagenr("$") do
    vim.cmd((current_tab + 1) .. "tabclose" .. (command.bang and "!" or ""))
  end
  vim.o.eventignore = ei
end, { bang = true, nargs = 0 })

vim.api.nvim_create_user_command("TabcloseLeft", function(command)
  local ei = vim.o.eventignore
  vim.opt.eventignore:append({ "TabClosed" })
  while vim.fn.tabpagenr() > 1 do
    vim.cmd("1tabclose" .. (command.bang and "!" or ""))
  end
  vim.o.eventignore = ei
end, { bang = true, nargs = 0 })

vim.api.nvim_create_user_command("Tabonly", function(command)
  local ei = vim.o.eventignore
  vim.opt.eventignore:append({ "TabClosed" })
  vim.cmd("tabonly" .. (command.bang and "!" or ""))
  vim.o.eventignore = ei
end, { bang = true, nargs = 0 })

vim.api.nvim_create_user_command("Tabclose", function(command)
  local ei = vim.o.eventignore
  vim.opt.eventignore:append({ "TabClosed" })
  vim.cmd("tabclose" .. (command.bang and "!" or ""))
  vim.o.eventignore = ei
end, { bang = true, nargs = 0 })

vim.api.nvim_create_user_command("Tabnew", function()
  require("lbrayner").preserve_view_port(function()
    vim.cmd("tabedit %")
  end)
end, { nargs = 0 })

vim.api.nvim_create_user_command("Tabedit", function()
  vim.cmd("Tabnew")
end, { nargs = 0 })
