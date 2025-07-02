vim.api.nvim_create_user_command("DeleteTrailingWhitespace", function(command)
  require("lbrayner").preserve_view_port(function()
    vim.cmd(string.format([[keeppatterns %d,%ds/\s\+$//e]], command.line1, command.line2))
  end)
end, { bar = true, nargs = 0, range = "%" })
vim.keymap.set("ca", "D", "DeleteTrailingWhitespace")

vim.api.nvim_create_user_command("Number", require("lbrayner").set_number, { nargs = 0 })

vim.api.nvim_create_user_command("Filter", function(command)
  local line_start = command.line1
  local line_end = command.line2
  local offset = 0
  for linenr = line_start, line_end do
    vim.api.nvim_win_set_cursor(0, { linenr + offset, 0 })
    local output = vim.fn.systemlist(vim.fn.getline(linenr + offset))
    vim.cmd.delete()
    vim.fn.append(linenr + offset - 1, output)
    if not vim.tbl_isempty(output) then
      offset = offset + #output - 1
    end
  end
  vim.api.nvim_win_set_cursor(0, { line_start, 0 })
end, { nargs = 0, range = true })

vim.api.nvim_create_user_command("LuaModuleReload", function(command)
  local module, replacements
  module = string.gsub(command.args, "^lua/", "")
  module, replacements = string.gsub(module, "/", ".")
  if replacements > 0 then
    module = string.gsub(module, "%.lua$", "")
  end
  package.loaded[module] = nil
  require(module)
  vim.notify(string.format("Reloaded '%s'.", module))
end, { bar = true, nargs = 1 })

-- https://stackoverflow.com/a/2573758
-- Inspired by the TabMessage function/command combo found at <http://www.jukie.net/~bart/conf/vimrc>.
vim.api.nvim_create_user_command("RedirMessages", function(command)
  vim.cmd("redir => message")
  vim.cmd(string.format("silent %s", command.args))
  vim.cmd("redir END")
  vim.cmd("silent put=message")
end, { complete = "command", nargs = "+" })

-- https://vi.stackexchange.com/a/36414
local function source(line_start, line_end, vimscript)
  local tempfile = vim.fn.tempname()

  if not vimscript then
    tempfile = tempfile..".lua"
  end

  vim.cmd(string.format("silent %d,%dwrite %s", line_start, line_end, vim.fn.fnameescape(tempfile)))
  vim.cmd.source(vim.fn.fnameescape(tempfile))
  vim.fn.delete(tempfile)

  if line_start == line_end then
    vim.cmd.echomsg(string.format("'Sourced line %d.'", line_start))
    return
  end

  vim.cmd.echomsg(string.format("'Sourced lines %d to %d.'", line_start, line_end))
end

vim.api.nvim_create_user_command("Source", function(command)
  source(command.line1, command.line2)
end, { nargs = 0, range = true })

vim.api.nvim_create_user_command("VimscriptSource", function(command)
  source(command.line1, command.line2, true)
end, { nargs = 0, range = true })
