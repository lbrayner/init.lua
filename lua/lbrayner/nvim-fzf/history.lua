local concat = table.concat
local fnamemodify = vim.fn.fnamemodify
local shellescape = vim.fn.shellescape

local M = {}

function M.get_history_file(suffix)
  assert(not suffix or type(suffix) == "string", "'suffix' must be a string")

  local history_file

  if vim.go.shadafile == "" then
    history_file = "fzf_history_main"
  else
    local shadafile = fnamemodify(fnamemodify(vim.go.shadafile, ":r"), ":t")

    history_file = concat({ "fzf_history_", shadafile })
  end

  if suffix then
    history_file = concat({ history_file, "_", suffix })
  end

  return vim.fs.joinpath(vim.fn.stdpath("cache"), history_file)
end

function M.sanitize_history_file(history_file)
  local history_file_ = shellescape(history_file)

  if vim.fn.executable("nauniq") == 1 then
    local cmd = concat({ "tac", history_file_, "| nauniq | tac | sponge", history_file_ }, " ")

    pcall(vim.system, { "sh", "-c", cmd }, { text = true }, vim.schedule_wrap(function(obj)
      if obj.code ~= 0 then
        vim.notify(string.format(
          "Could not run '%s': %s", cmd, obj.stderr
        ), vim.log.levels.ERROR)
      end
    end))
  end
end

return M
