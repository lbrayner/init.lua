vim.keymap.set("n", "<Leader>di", "<Cmd>windo diffthis<CR>")
vim.keymap.set("n", "<Leader>dw", function() -- toggle iwhite
  if string.find(vim.go.diffopt, "iwhite") then
    vim.opt.diffopt:remove({ "iwhite" })
    vim.notify("-iwhite")
    return
  end
  vim.opt.diffopt:append({ "iwhite" })
  vim.notify("+iwhite")
end)
vim.keymap.set("n", "<Leader>do", "<Cmd>diffoff!<CR>")

-- TODO for tackling a vim-fugitive bug, reproduce and submit a bug report
local diffupdate = vim.api.nvim_create_augroup("diffupdate", { clear = false })
vim.api.nvim_create_autocmd("TabEnter" , {
  group = diffupdate,
  callback = function(args)
    local winid = vim.fn.bufwinid(args.buf)
    if not winid then return end
    if vim.wo[winid].diff then
      vim.cmd.diffupdate()
    end
  end,
})

local function update_conflict_markers(bufnr)
  require("lbrayner.ripgrep").lrg([["^(<<<<<<<|\|\|\|\|\|\|\||=======|>>>>>>>)" ]] ..
  vim.fn.shellescape(vim.api.nvim_buf_get_name(0)))
  if not vim.tbl_isempty(vim.fn.getloclist(0)) then
    vim.fn.setloclist(0, {}, "a", { title = "Conflict markers" })
    return true
  end
  return false
end

local function clear_conflict_markers_autocmd(bufnr)
  pcall(vim.api.nvim_del_autocmd, vim.b[bufnr].conflict_marker_autocmd)
end

vim.api.nvim_create_user_command("ConflictMarkers", function()
  local bufnr = vim.api.nvim_get_current_buf()
  if update_conflict_markers(bufnr) then
    clear_conflict_markers_autocmd(bufnr)
    local conflict_markers = vim.api.nvim_create_augroup("conflict_markers", { clear = false })
    vim.b[bufnr].conflict_marker_autocmd = vim.api.nvim_create_autocmd({ "BufWritePost", "WinEnter" }, {
      group = conflict_markers,
      buffer = bufnr,
      callback = function(args)
        local bufnr = args.buf
        if vim.api.nvim_get_current_buf() ~= bufnr then
          -- After a buf_write_post, do nothing if bufnr is not current
          return
        end
        if vim.fn.getloclist(vim.api.nvim_get_current_win(), { title = 1 }).title == "Conflict markers" then
          local qfbufnr = vim.fn.getloclist(0, { qfbufnr = 1 }).qfbufnr
          if vim.fn.getbufvar(qfbufnr, "conflict_marker_tick") < vim.b.changedtick then
            if not update_conflict_markers(bufnr) then
              vim.cmd.lclose()
              clear_conflict_markers_autocmd(bufnr)
              return
            end
            vim.b[bufnr].conflict_marker_tick = vim.b.changedtick
          end
        end
      end,
    })

    local changedtick = vim.b.changedtick
    vim.cmd.lopen()
    vim.b.conflict_marker_tick = changedtick
  else
    vim.notify("No conflict markers found.")
  end
end, { nargs = 0 })
