vim.go.showtabline = 2

local is_in_directory = require("lbrayner").is_in_directory

local function redefine_tabline()
  -- Is this a session?
  local session_name = require("lbrayner").get_session()
  local session = session_name == "" and "" or string.format("%%#Question#(%s)%%#Normal# ", session_name)
  -- To be displayed on the left side
  local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
  local tabline = string.format("%%#Title#%%4.{tabpagenr()} %%#Normal#%s%%#NonText#%s", session, cwd)
  -- At least one column separating left and right and a 1 column margin
  local max_length = vim.go.columns - 3 - 1 - 1 - #session_name - 1 - #cwd - 1 - 1

  if vim.fn.exists("*FugitiveResult") then
    local fugitive_result = vim.fn.FugitiveResult(vim.api.nvim_get_current_buf())
    if fugitive_result.filetype and
      fugitive_result.blame_file and
      fugitive_result.filetype == "fugitiveblame" then -- Fugitive blame
      local blame = "Fugitive blame: "
      max_length = max_length - #blame
      local filename = vim.fn.FugitiveResult(vim.api.nvim_get_current_buf()).blame_file
      filename = vim.fn["util#truncateFilename"](filename, max_length)
      vim.go.tabline = tabline .. string.format(" %%=%%#WarningMsg#%s%%#Normal#%s ", blame, filename)
      return
    end
  end

  if vim.fn.exists("*FugitiveResult") and
    not vim.tbl_isempty(vim.fn.FugitiveResult(vim.api.nvim_get_current_buf())) then  -- Fugitive temporary buffers
    tabline = tabline .. " %="
    local fcwd = vim.fn.FugitiveResult(vim.api.nvim_get_current_buf()).cwd
    if not is_in_directory(fcwd, vim.fn.getcwd()) then
      fcwd = vim.fn.pathshorten(vim.fn.fnamemodify(fcwd, ":~"))
      max_length = max_length - #fcwd
      tabline = tabline .. string.format("%%<%%#WarningMsg#%s ", fcwd)
    end
    local truncated_filename = vim.fn["util#truncateFilename"](vim.api.nvim_buf_get_name(0), max_length)
    tabline = tabline .. string.format("%%#Normal#%s ", truncated_filename)
  elseif vim.fn.exists("*FugitiveParse") and vim.fn.FObject() ~= "" then -- Fugitive objects
    local name_dir = vim.fn.FugitiveParse(vim.api.nvim_buf_get_name(0))
    local dir = name_dir[2]
    dir = string.gsub(dir, "/%.git$", "") -- Fugitive summary
    if not is_in_directory(dir, vim.fn.getcwd()) then
      local truncated_dirname = vim.fn["util#truncateFilename"](vim.fn.fnamemodify(dir, ":~"), max_length)
      tabline = tabline .. string.format(" %%=%%#WarningMsg#%s ", truncated_dirname)
    end
  elseif not vim.startswith(vim.api.nvim_buf_get_name(0), "jdt://") and -- jdtls
    vim.bo.buftype ~= "terminal" then
    local name = vim.api.nvim_buf_get_name(0)
    if name ~= "" and not is_in_directory(name, vim.fn.getcwd()) then -- It's an absolute path
      local absolute_path = vim.fn["util#truncateFilename"](vim.fn.fnamemodify(name, ":~"), max_length)
      tabline = tabline .. string.format(" %%=%%#WarningMsg#%s ", absolute_path)
    end
  end

  vim.go.tabline = tabline
end

local tabline = vim.api.nvim_create_augroup("tabline", { clear = true })

vim.api.nvim_create_autocmd("VimEnter", {
  group = tabline,
  callback = function()
    vim.api.nvim_create_autocmd({ "BufEnter", "BufFilePost", "BufWritePost", "DirChanged", "WinEnter" }, {
      group = tabline,
      callback = function()
        if not require("lbrayner").window_is_floating() then
          redefine_tabline()
        end
      end,
    })
    if not require("lbrayner").window_is_floating() then
      redefine_tabline()
    end
  end,
})

if vim.v.vim_did_enter == 1 then
  vim.api.nvim_exec_autocmds("VimEnter", { group = tabline })
end
