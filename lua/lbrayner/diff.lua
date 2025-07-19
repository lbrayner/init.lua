vim.keymap.set("n", "<Leader>di", "<Cmd>windo diffthis<CR>")
vim.keymap.set("n", "<Leader>dw", function() -- toggle iwhite
  if require("lbrayner").contains(vim.go.diffopt, "iwhite") then
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

vim.api.nvim_create_user_command("ConflictMarkers", function()
  local function clear_conflict_markers_autocmd(bufnr)
    pcall(vim.api.nvim_del_autocmd, vim.b[bufnr].conflict_marker_autocmd)
  end

  local function update_conflict_markers(bufnr)
    require("lbrayner.ripgrep").rg(
      [["^(<<<<<<<|\|\|\|\|\|\|\||=======|>>>>>>>)" ]] ..
      vim.fn.shellescape(vim.api.nvim_buf_get_name(0)),
      { loclist = 0 },
      { code1 = "No conflict markers found.", title = "Conflict markers" }
    )
  end

  local function update_context(changedtick)
    local context = vim.tbl_extend(
      "keep",
      { conflict_markers = { changedtick = changedtick } },
      vim.fn.getloclist(0, { context = 1 }).context
    )

    vim.fn.setloclist(0, {}, "a", { context = context })
  end

  local bufnr = vim.api.nvim_get_current_buf()
  update_conflict_markers(bufnr)
  clear_conflict_markers_autocmd(bufnr)

  local conflict_markers = vim.api.nvim_create_augroup("conflict_markers", { clear = false })

  vim.b[bufnr].conflict_marker_autocmd = vim.api.nvim_create_autocmd({ "BufWritePost", "WinEnter" }, {
    group = conflict_markers,
    buffer = bufnr,
    callback = function(args)
      local bufnr = args.buf

      if vim.api.nvim_get_current_buf() ~= bufnr then
        -- After a BufWritePost do nothing if bufnr is not current
        return
      end

      if vim.fn.getloclist(0, { title = 1 }).title == "Conflict markers" then
        local loclist = vim.fn.getloclist(0, { context = 1, items = 1 })
        print("loclist", vim.inspect(loclist)) -- TODO debug

        if vim.tbl_isempty(loclist.items) then
          return vim.tbl_isempty(loclist.items)
        end

        local context = loclist.context

        if args.event == "WinEnter" and
          not vim.tbl_get(context, "conflict_markers", "changedtick") then
          update_context(vim.b.changedtick)
          return
        end

        if not vim.tbl_get(context, "conflict_markers", "changedtick") or
          context.conflict_markers.changedtick < vim.b.changedtick then
          update_context(vim.b.changedtick)
          update_conflict_markers(bufnr)
        end
      end
    end,
  })
end, { nargs = 0 })
