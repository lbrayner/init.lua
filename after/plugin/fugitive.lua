if vim.fn.exists("*FugitiveParse") == 0 then
  return
end

vim.keymap.set("ca", "Gb", "Git blame --abbrev=6")
vim.keymap.set("ca", "Gc", "Git checkout")
vim.keymap.set("ca", "Gd", "Git difftool -y")
vim.keymap.set("ca", "Gdd", "Git difftool -y  -- :^package-lock.json<S-Left><S-Left><Left>")
-- To list files modified by a range of commits
vim.keymap.set("ca", "Gdn", "Git diff --name-only --stat")
vim.keymap.set("ca", "Gf", "Git! fetch upstream")
vim.keymap.set("ca", "Gl", "Git log")
vim.keymap.set("ca", "Glns", "Git log --name-status")
vim.keymap.set("ca", "Glo", "Git log --oneline")
-- To list branches of a specific remote: Git! ls-remote upstream
vim.keymap.set("ca", "Gls", "Git! ls-remote")
vim.keymap.set("ca", "Gp", "Git cherry-pick")
vim.keymap.set("ca", "Gr", "Git rebase -i")
vim.keymap.set("ca", "Gs", "Git stash")
-- git bash and zsh autocomplete should complete --keep-index
vim.keymap.set("ca", "Gsk", "Git stash --keep-index")
vim.keymap.set("ca", "Gt", "Git! ls-tree -r --name-only")
-- Only list tags whose tips are reachable from the specified commit
vim.keymap.set("ca", "Gtm", "Git tag --merged")

vim.api.nvim_create_user_command("FugitiveObject", function()
  local fugitive_object = require("lbrayner.fugitive").fugitive_object()
  if not fugitive_object then
    vim.notify("This buffer is not a Fugitive object.")
    return
  end
  require("lbrayner.clipboard").clip(fugitive_object)
end, { nargs = 0 })
vim.api.nvim_create_user_command("FugitiveUrl", function()
  local fugitive_object = require("lbrayner.fugitive").fugitive_object()
  if not fugitive_object then
    vim.notify("This buffer is not a Fugitive object.")
    return
  end
  require("lbrayner.clipboard").clip(vim.api.nvim_buf_get_name(0))
end, { nargs = 0 })
vim.api.nvim_create_user_command("Gdi", function(command)
  local args = command.args
  if args == "" then
    local relative = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":.")
    args = ":0:./" .. relative
  end
  vim.fn["fugitive#Diffsplit"](1, command.bang and 0 or 1, "leftabove <mods>", args)
end, { bang = true, bar = true, complete = "customlist,fugitive#EditComplete", nargs = "*" })

local function fugitive_map_overrides(bufnr)
  local bufopts = { buffer = bufnr }
  pcall(vim.keymap.del, "n", "<C-W>f", bufopts)
  pcall(vim.keymap.del, "n", "<C-W>gf", bufopts)
  pcall(vim.keymap.del, "v", "*", bufopts)
  pcall(vim.keymap.del, "n", "*", bufopts)
end

local fugitive_customization = vim.api.nvim_create_augroup("fugitive_customization", { clear = true })

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "fugitive://*//*",
  group = fugitive_customization,
  callback = function(args)
    vim.bo[args.buf].modifiable = false
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "fugitive", "fugitiveblame", "git", "gitcommit" },
  group = fugitive_customization,
  callback = function(args)
    local bufnr = args.buf
    local filetype = args.match

    if filetype == "fugitive" then
      fugitive_map_overrides(bufnr)
      vim.cmd("Glcd")
    elseif filetype == "fugitiveblame" then
      vim.keymap.set("n", "q", function()
        vim.api.nvim_win_close(0, false)
      end, { buffer = bufnr, nowait = true })
    elseif filetype == "git" then
      fugitive_map_overrides(bufnr)
      vim.bo[args.buf].includeexpr = "v:lua.require'lbrayner.fugitive'.diff_include_expression(v:fname)"
    elseif filetype == "gitcommit" then
      fugitive_map_overrides(bufnr)
    end
  end,
})
