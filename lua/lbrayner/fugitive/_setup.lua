if vim.fn.exists("*FugitiveParse") == 0 then
  return
end

vim.keymap.set("ca", "Gb", "Git blame --abbrev=6")
vim.keymap.set("ca", "Gc", "Git checkout")
vim.keymap.set("ca", "Gd", "Git difftool -y")
vim.keymap.set("ca", "Gdd", "Git difftool -y  -- :^package-lock.json<S-Left><S-Left><Left>")
-- To list files modified by a range of commits
vim.keymap.set("ca", "Gdn", "Git diff --name-only --stat")
vim.keymap.set("ca", "Gf", "Git! fetch origin")
vim.keymap.set("ca", "Gl", "Git log")
vim.keymap.set("ca", "Glf", "Git! ls-files")
vim.keymap.set("ca", "Glns", "Git log --name-status")
vim.keymap.set("ca", "Glo", "Git log --oneline")
-- To list branches of a specific remote: Git! ls-remote upstream
vim.keymap.set("ca", "Glr", "Git! ls-remote origin")
-- List all files of a local or remote commit, branch (tree-ish)
vim.keymap.set("ca", "Glt", "Git! ls-tree -r")
vim.keymap.set("ca", "Gp", "Git cherry-pick")
vim.keymap.set("ca", "Gr", "Git rebase -i")
vim.keymap.set("ca", "Gs", "Git stash")
-- git bash and zsh autocomplete should complete --keep-index
vim.keymap.set("ca", "Gsk", "Git stash --keep-index")
-- Only list tags whose tips are reachable from the specified commit
vim.keymap.set("ca", "Gtm", "Git tag --merged")

vim.api.nvim_create_user_command("FugitiveObject", function()
  local fugitive_object = require("lbrayner.fugitive").get_fugitive_object()
  if not fugitive_object then
    vim.notify("This buffer is not a Fugitive object.")
    return
  end
  require("lbrayner.clipboard").clip(fugitive_object)
end, { nargs = 0 })
vim.api.nvim_create_user_command("FugitiveUrl", function()
  local fugitive_object = require("lbrayner.fugitive").get_fugitive_object()
  if not fugitive_object then
    vim.notify("This buffer is not a Fugitive object.")
    return
  end
  require("lbrayner.clipboard").clip(vim.api.nvim_buf_get_name(0))
end, { nargs = 0 })
vim.api.nvim_create_user_command("Gdi", function(command)
  local args = command.args
  local bufname = vim.api.nvim_buf_get_name(0)
  if args == "" and require("lbrayner.path").is_in_directory(bufname, vim.fn.getcwd()) then
    local relative = vim.fn.fnamemodify(bufname, ":.")
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
    local file = args.match

    if not require("lbrayner").contains(file, "//0/") then -- Staging area
      vim.bo.modifiable = false
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "fugitive", "fugitiveblame", "git", "gitcommit" },
  group = fugitive_customization,
  callback = function(args)
    local bufnr = args.buf
    local filetype = args.match

    if filetype == "git" and not vim.b[bufnr].fugitive_type then
      -- jdtls code actions preview buffers are now of filetype "git"
      return
    end

    if filetype == "fugitive" then
      fugitive_map_overrides(bufnr)
      vim.cmd("Glcd")
    elseif filetype == "fugitiveblame" then
      vim.keymap.set("n", "q", function()
        vim.api.nvim_win_close(0, false)
      end, { buffer = bufnr, nowait = true })
    elseif filetype == "git" then
      fugitive_map_overrides(bufnr)
      vim.bo.includeexpr = "v:lua.require'lbrayner.fugitive'.include_expression(v:fname)"
      vim.cmd("Glcd")
    elseif filetype == "gitcommit" then
      fugitive_map_overrides(bufnr)
      vim.cmd("Glcd")
    end
  end,
})
