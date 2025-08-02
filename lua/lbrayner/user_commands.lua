local fnameescape = vim.fn.fnameescape
local nvim_create_user_command = vim.api.nvim_create_user_command
local format = string.format

nvim_create_user_command("DeleteTrailingWhitespace", function(opts)
  require("lbrayner").preserve_view_port(function()
    vim.cmd(format([[keeppatterns %d,%ds/\s\+$//e]], opts.line1, opts.line2))
  end)
end, { bar = true, nargs = 0, range = "%" })
vim.keymap.set("ca", "D", "DeleteTrailingWhitespace")

nvim_create_user_command("Number", require("lbrayner").set_number, { nargs = 0 })

nvim_create_user_command("Filter", function(opts)
  local line_start = opts.line1
  local line_end = opts.line2
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

nvim_create_user_command("LuaModuleReload", function(opts)
  local module, replacements = string.gsub(opts.args, "^lua/", "")

  if replacements == 0 then
    module = string.gsub(module, "^vim/dot%-local/share/nvim/site/lua/", "")
  end

  module, replacements = string.gsub(module, "/", ".")

  if replacements > 0 then
    module, replacements = string.gsub(module, "%.init%.lua$", "")

    if replacements == 0 then
      module = string.gsub(module, "%.lua$", "")
    end
  end

  package.loaded[module] = nil
  require(module)
  vim.notify(format("Reloaded '%s'.", module))
end, { bar = true, nargs = 1 })

-- https://stackoverflow.com/a/2573758
-- Inspired by the TabMessage function/command combo found at <http://www.jukie.net/~bart/conf/vimrc>.
nvim_create_user_command("RedirMessages", function(opts)
  vim.cmd("redir => message")
  vim.cmd(format("silent %s", opts.args))
  vim.cmd("redir END")
  vim.cmd("silent put=message")
end, { complete = "command", nargs = "+" })

-- https://vi.stackexchange.com/a/36414
local function source(line_start, line_end, vimscript)
  local tempfile = vim.fn.tempname()

  if not vimscript then
    tempfile = tempfile..".lua"
  end

  vim.cmd(format("silent %d,%dwrite %s", line_start, line_end, fnameescape(tempfile)))
  vim.cmd.source(fnameescape(tempfile))
  vim.fn.delete(tempfile)

  if line_start == line_end then
    vim.cmd.echomsg(format("'Sourced line %d.'", line_start))
    return
  end

  vim.cmd.echomsg(format("'Sourced lines %d to %d.'", line_start, line_end))
end

nvim_create_user_command("Source", function(opts)
  source(opts.line1, opts.line2)
end, { nargs = 0, range = true })

nvim_create_user_command("VimscriptSource", function(opts)
  source(opts.line1, opts.line2, true)
end, { nargs = 0, range = true })
