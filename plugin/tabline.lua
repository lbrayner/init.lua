vim.go.showtabline = 2

local function redefine_tabline()
  -- Is this a session?
  local session_name = vim.fn["util#getSession"]()
  local session = session_name == "" and "" or "%#Question#" .. "(" .. session_name .. ")" .. "%#Normal# "
  -- To be displayed on the left side
  local cwd = vim.fn["util#NPath"](vim.fn.getcwd())
  vim.go.tabline = "%#Title#%4.{tabpagenr()}%#Normal# "..session.."%#NonText#"..cwd
  -- At least one column separating left and right and a 1 column margin
  local max_length = vim.go.columns - 3 - 1 - 1 - #session_name - 1 - #cwd - 1 - 1
  -- Fugitive blame
  if vim.fn.exists("*FugitiveResult") then
    local fugitive_result = vim.fn.FugitiveResult(vim.api.nvim_get_current_buf())
    if fugitive_result.filetype and
      fugitive_result.blame_file and
      fugitive_result.filetype == "fugitiveblame" then
      vim.go.tabline = vim.go.tabline .. " %="
      local blame="Fugitive blame: "
      max_length = max_length - #blame
      local filename = vim.fn.FugitiveResult(vim.api.nvim_get_current_buf()).blame_file
      filename = vim.fn["util#truncateFilename"](filename, max_length)
      vim.go.tabline = vim.go.tabline .. "%#WarningMsg#"..blame.."%#Normal#"..filename.." "
      return
    end
  end
  -- Fugitive temporary buffers
  if vim.fn.exists("*FugitiveResult") and
    not vim.tbl_isempty(vim.fn.FugitiveResult(vim.api.nvim_get_current_buf())) then
    vim.go.tabline = vim.go.tabline .. " %="
    local fcwd = vim.fn.FugitiveResult(vim.api.nvim_get_current_buf()).cwd
    if vim.fn["util#IsInDirectory"](vim.fn.getcwd(), fcwd) == 0 then
      fcwd = vim.fn["util#NPath"](fcwd)
      max_length = max_length - #fcwd
      vim.go.tabline = vim.go.tabline .. "%<%#WarningMsg#"..fcwd.." "
    end
    vim.go.tabline = vim.go.tabline .. "%#Normal#" ..
      vim.fn["util#truncateFilename"](vim.fn.expand("%"), max_length).." "
    return
  end
  -- Fugitive objects
  if vim.fn.exists("*FugitiveParse") and vim.fn.FObject() ~= "" then -- Fugitive objects
    local name_dir = vim.fn.FugitiveParse(vim.fn.expand("%"))
    local dir = name_dir[2]
    dir = string.gsub(dir, "/%.git$", "")
    -- Fugitive summary
    vim.go.tabline = vim.go.tabline .. " %="
    if vim.fn["util#IsInDirectory"](vim.fn.getcwd(), dir) == 0 then
      vim.go.tabline = vim.go.tabline .. "%#WarningMsg#"..vim.fn["util#truncateFilename"](vim.fn["util#NPath"](dir), max_length).." "
    end
    return
  end
  -- jdtls
  if string.find(vim.api.nvim_buf_get_name(0), "^jdt://") then -- jdtls
    return
  end
  if vim.bo.buftype == "terminal" then
    return
  end
  -- It's an absolute path
  if vim.fn.expand("%") ~= "" and not vim.fn["util#IsInDirectory"](vim.fn.getcwd(), vim.fn.expand("%")) then
    local absolute_path = vim.fn["util#truncateFilename"](vim.fn["util#NPath"](vim.fn.expand("%")), max_length)
    vim.go.tabline = vim.go.tabline .. " %=%#WarningMsg#" .. absolute_path .. " "
    return
  end
end

local tabline = vim.api.nvim_create_augroup("tabline", { clear = true })

vim.api.nvim_create_autocmd("VimEnter", {
  group = tabline,
  callback = function()
    vim.api.nvim_create_autocmd({ "BufFilePost", "BufWritePost", "DirChanged", "WinEnter" }, {
      group = tabline,
      callback = redefine_tabline,
    })
    vim.api.nvim_create_autocmd("BufEnter", {
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
