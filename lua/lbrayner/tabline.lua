local M = {}

vim.go.showtabline = 2

local is_in_directory = require("lbrayner.path").is_in_directory
local len = string.len
local truncate_filename = require("lbrayner").truncate_filename

function M.redefine_tabline()
  -- Is this a session?
  local session_name = require("lbrayner").get_session()
  local session = session_name == "" and "" or string.format("%%#Question#(%s)%%#Normal# ", session_name)
  -- To be displayed on the left side
  local cwd = require("lbrayner.path").cwd()
  local tabline = string.format("%%#Title#%%4.{tabpagenr()} %s%%#Directory#%s", session, cwd)
  -- 1 column margins, 3 columns for tab number, spaces between tab, session, cwd etc.
  local max_length = vim.go.columns - 1 - 3 - 1 -
  (session_name == "" and 0 or 1 + len(session_name) + 1 + 1) - len(cwd) - 1

  if vim.fn.exists("*FugitiveResult") == 1 then
    local fugitive_result = vim.fn.FugitiveResult(vim.api.nvim_get_current_buf())
    if fugitive_result.filetype and
      fugitive_result.blame_file and
      fugitive_result.filetype == "fugitiveblame" then -- Fugitive blame
      local blame = "Fugitive blame: "
      max_length = max_length - len(blame)
      local filename = vim.fn.FugitiveResult(vim.api.nvim_get_current_buf()).blame_file
      filename = truncate_filename(filename, max_length)
      vim.go.tabline = tabline .. string.format(" %%=%%#WarningMsg#%s%%#Normal#%s ", blame, filename)
      return
    end
  end

  local bufname = vim.api.nvim_buf_get_name(0)

  if vim.fn.exists("*FugitiveResult") == 1 and
    not vim.tbl_isempty(vim.fn.FugitiveResult(vim.api.nvim_get_current_buf())) then -- Fugitive temporary buffers
    tabline = tabline .. " %="
    local fcwd = vim.fn.FugitiveResult(vim.api.nvim_get_current_buf()).cwd
    if not is_in_directory(fcwd, vim.fn.getcwd()) then
      fcwd = vim.fn.pathshorten(vim.fn.fnamemodify(fcwd, ":~"))
      max_length = max_length - len(fcwd)
      tabline = tabline .. string.format("%%<%%#WarningMsg#%s ", fcwd)
    end
    local truncated_filename = truncate_filename(bufname, max_length)
    tabline = tabline .. string.format("%%#Normal#%s ", truncated_filename)
  elseif require("lbrayner.fugitive").fugitive_object() then
    local name_dir = vim.fn.FugitiveParse(bufname)
    local dir = name_dir[2]
    dir = string.gsub(dir, "/%.git$", "") -- Fugitive summary
    if not is_in_directory(dir, vim.fn.getcwd()) then
      dir = vim.fs.normalize(vim.fn.fnamemodify(dir, ":p")) -- Remove trailing /
      local trunc_dir = truncate_filename(vim.fn.fnamemodify(dir, ":~"), max_length)
      tabline = tabline .. string.format(" %%=%%#WarningMsg#%s ", trunc_dir)
    end
  elseif not vim.startswith(bufname, "jdt://") and -- jdtls
    not vim.startswith(bufname, "term://") then -- buftype set to "terminal" too late, check bufname
    if bufname ~= "" and not is_in_directory(bufname, vim.fn.getcwd()) then -- It's an absolute path
      bufname = require("lbrayner.path").full_path()
      max_length = max_length - 1 -- a space
      local absolute_path = truncate_filename(bufname, max_length)
      tabline = tabline .. string.format(" %%=%%#WarningMsg#%s ", absolute_path)
    end
  end

  vim.go.tabline = tabline
end

vim.api.nvim_create_user_command("RedefineTabline", M.redefine_tabline, { nargs = 0 })

local tabline = vim.api.nvim_create_augroup("tabline", { clear = true })

vim.api.nvim_create_autocmd("VimEnter", {
  group = tabline,
  callback = function()
    vim.api.nvim_create_autocmd({ "BufEnter", "BufFilePost", "BufWritePost", "DirChanged", "WinEnter" }, {
      group = tabline,
      callback = function(args)
        local bufnr = args.buf
        if vim.api.nvim_get_current_buf() ~= bufnr then
          -- After a BufWritePost, do nothing if bufnr is not current
          return
        end
        if not require("lbrayner").window_is_floating() then
          M.redefine_tabline()
        end
      end,
    })
    if not require("lbrayner").window_is_floating() then
      M.redefine_tabline()
    end
  end,
})

if vim.v.vim_did_enter == 1 then
  vim.api.nvim_exec_autocmds("VimEnter", { group = tabline })
end

return M
