-- vim: fdm=marker

local M = {}

local actions = require("fzf-lua.actions")
local fzf = require("fzf-lua")

function M.buffers()
  fzf.buffers(
    M.make_opts({
      fzf_opts = { ["--history"] = M.get_history_file() },
      show_unlisted = true,
    })
  )
end

local function fzf_files(opts) -- {{{
  opts = vim.tbl_deep_extend("keep", {
    -- https://github.com/ibhagwan/fzf-lua/issues/996
    -- actions.files refers to all pickers that deal with files which also
    -- includes grep, etc. Toggle ignore action is defined specifically for
    -- files
    actions = { ["ctrl-g"] = false },
    fzf_opts = { ["--history"] = M.get_history_file() }
  }, opts)

  if vim.startswith(opts.cmd, "find_file_cache") then
    opts.git_icons = false
  end

  fzf.files(M.make_opts(opts))
end -- }}}

function M.files_clear_cache(opts)
  opts = opts or {}
  local args = opts.args or ""
  local cmd = string.format("%s %s", "find_file_cache -C", args)

  if vim.fn.executable("find_file_cache") == 0 then
    vim.notify("find_file_cache not executable.", vim.log.levels.ERROR)
    return
  end

  fzf_files({ cmd = cmd })
  vim.notify("Cleared FZF cache.")
end

function M.files(opts)
  opts = opts or {}
  local args = opts.args or ""
  local cmd

  if vim.fn.executable("find_file_cache") == 1 then
    cmd = "find_file_cache"
  elseif vim.fn.executable("rg") == 1 then
    cmd = "rg --files --sort path"
  end

  cmd = string.format("%s %s", cmd, args)

  fzf_files({ cmd = cmd })
end

function M.file_marks()
  local function file_mark_jump_to_location(selected, _)
    local mark = selected[1]
    mark = mark:match("%u") -- Uppercase letters
    require("lbrayner.marks").file_mark_jump_to_location(mark)
  end

   -- Ignore error "No marks matching..."
  pcall(fzf.marks, M.make_opts({
    actions = {
      ["enter"] = file_mark_jump_to_location,
    },
    fzf_opts = { ["--history"] = M.get_history_file("file_marks") },
    marks = "[A-Z]",
    prompt = "File marks> "
  }))
end

function M.get_history_file(suffix)
  assert(not suffix or type(suffix) == "string", "'suffix' must be a string")

  local history_file

  if vim.go.shadafile == "" then
    history_file = "fzf_history_main"
  else
    local fnamemodify = vim.fn.fnamemodify
    local shadafile = fnamemodify(fnamemodify(vim.go.shadafile, ":r"), ":t")

    history_file = "fzf_history_" .. shadafile
  end

  if suffix then
    history_file = history_file .. "_" .. suffix
  end

  return vim.fs.joinpath(vim.fn.stdpath("cache"), history_file)
end

function M.help_tags()
  fzf.help_tags(M.make_opts({
    actions = { ["alt-s"] = actions.help_vert },
    fzf_opts = { ["--history"] = M.get_history_file("help_tags") },
  }))
end

function M.make_opts(opts)
  opts = opts or {}

  local history_file = vim.tbl_get(opts, "fzf_opts", "--history")

  if not history_file then return opts end

  if vim.fn.executable("nauniq") == 0 then
    return opts
  end

  local cmd = "tac " .. history_file .. " | nauniq | tac | sponge " .. history_file

  opts.winopts = opts.winopts or {}

  opts.winopts.on_close = function()
    vim.system({ "sh", "-c", cmd }, { text = true }, vim.schedule_wrap(function(obj)
      if obj.code ~= 0 then
        vim.notify(string.format(
          "Could not run '%s': %s", cmd, obj.stderr
        ), vim.log.levels.ERROR)
      end
    end))
  end

  return opts
end

function M.tabs()
  fzf.tabs(M.make_opts({
    fzf_opts = {
      ["--history"] = M.get_history_file(),
      ["--preview"] = 'echo "Tab #"{2}": $(echo {1} | base64 -d -)"',
      ["--preview-window"] = "nohidden:up,1",
    },
    show_quickfix = true,
    show_unlisted = true
  }))
end

return M
