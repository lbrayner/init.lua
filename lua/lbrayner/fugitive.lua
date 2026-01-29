local FugitiveParse = vim.fn.FugitiveParse
local FugitiveReal = vim.fn.FugitiveReal
local exists = vim.fn.exists
local fnamemodify = vim.fn.fnamemodify
local nvim_buf_get_name = vim.api.nvim_buf_get_name

local M = {}

function M.include_expression(fname)
  -- diff hunks in vim-fugitive buffers
  local fname = string.gsub(fname, "^[ab]/", "")
  return fname
end

function M.get_fugitive_object(bufnr)
  bufnr = bufnr or 0

  if exists("*FugitiveParse") == 1 then
    local object = FugitiveParse(nvim_buf_get_name(bufnr))[1]
    if object ~= "" then
      return object
    end
  end
end

function M.get_fugitive_path()
  if exists("*FugitiveReal") == 1 then
    local path = fnamemodify(FugitiveReal(nvim_buf_get_name(0)), ":~:.")
    if path ~= "" then
      return path
    end
  end
end

function M.setup()
  require("lbrayner.fugitive._setup")
end

return M
