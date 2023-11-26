local M = {}

vim.api.nvim_create_user_command("OverlengthToggle", function()
  if not vim.w.overlength then
    vim.w.overlength = 90
  end
  local matches = vim.tbl_filter(function(hi)
    return hi.group == "Overlength"
  end, vim.fn.getmatches())
  if not vim.tbl_isempty(matches) then
    for _, matchd in ipairs(matches) do
      vim.fn.matchdelete(matchd.id)
    end
    vim.cmd.echo("'Overlength highlight cleared.'")
    return
  end
  vim.api.nvim_set_hl(0, "Overlength", { bg = "#592929" })
  vim.fn.matchadd("Overlength", string.format([[\%%%dv.\+]], vim.w.overlength))
  vim.cmd.echo("'Overlength highlighted.'")
end, { nargs = 0 })

function M.trailing_whitespace_group()
  vim.api.nvim_set_hl(0, "TrailingWhitespace", { bg = "#ff0000" })
end

M.trailing_whitespace_group()

function M.highlight_trailing_whitespace()
  if vim.bo.buftype == "terminal" then
    M.clear_trailing_whitespace()
  elseif vim.tbl_contains({ "help", "lspinfo", "netrw" }, vim.bo.syntax)  then
    M.clear_trailing_whitespace()
  elseif vim.tbl_contains({ "mail", "markdown" }, vim.bo.syntax) then
    M.clear_trailing_whitespace()
    vim.fn.matchadd("TrailingWhitespace", [[^\s\+$]])
  elseif vim.bo.syntax == "git" then
    M.clear_trailing_whitespace()
    -- Commit message paragraphs
    -- Git branch graphs
    -- Diffs
    vim.fn.matchadd("TrailingWhitespace", [[^\%( \{4}\zs\s\+\|[| ]\+| \{5}\zs\s\+\|[+-].*[^ 	]\+\zs\s\+\)$]])
    -- Neogit
  elseif vim.startswith(vim.bo.syntax, "Neogit") then
    M.clear_trailing_whitespace()
    -- Telescope
  elseif vim.tbl_contains({ "TelescopePrompt", "TelescopeResults" }, vim.bo.syntax) then
    M.clear_trailing_whitespace()
  else
    M.clear_trailing_whitespace()
    vim.fn.matchadd("TrailingWhitespace", [[\s\+$]])
  end
end

function M.clear_trailing_whitespace()
  local matches = vim.tbl_filter(function(hi)
    return hi.group == "TrailingWhitespace"
  end, vim.fn.getmatches())
  if not vim.tbl_isempty(matches) then
    for _, matchd in ipairs(matches) do
      vim.fn.matchdelete(matchd.id)
    end
  end
end

local highlight_trailing_white_space = vim.api.nvim_create_augroup("highlight_trailing_white_space", {
  clear = true })

vim.api.nvim_create_autocmd("ColorScheme", {
  group = highlight_trailing_white_space,
  callback = M.trailing_whitespace_group,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
  group = highlight_trailing_white_space,
  callback = M.highlight_trailing_whitespace,
})

vim.api.nvim_create_autocmd("VimEnter", {
  group = highlight_trailing_white_space,
  callback = function()
    vim.api.nvim_create_autocmd({ "Syntax", "TermOpen", "WinEnter" }, {
      group = highlight_trailing_white_space,
      callback = M.highlight_trailing_whitespace,
    })
    M.highlight_trailing_whitespace()
  end,
})

if vim.v.vim_did_enter == 1 then
  vim.api.nvim_exec_autocmds("VimEnter", { group = highlight_trailing_white_space })
end

return M
