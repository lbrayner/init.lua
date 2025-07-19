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
  local bufnr, conflict_marker_autocmd, id = vim.api.nvim_get_current_buf()
  local title = "Conflict markers"

  local function clear_conflict_markers_autocmd()
    pcall(vim.api.nvim_del_autocmd, conflict_marker_autocmd)
  end

  local function update_context(changedtick)
    if not id then error("'id' not set") end

    local loclist = vim.fn.getloclist(0, { context = 1, id = id })
    local context = vim.tbl_extend(
      "keep",
      { conflict_markers = { changedtick = changedtick } },
      loclist.context
    )

    vim.fn.setloclist(0, {}, "a", { context = context, id = id })
  end

  local function update_conflict_markers()
    require("lbrayner.ripgrep").rg(
      [["^(<<<<<<<|\|\|\|\|\|\|\||=======|>>>>>>>)" ]] ..
      vim.fn.shellescape(vim.api.nvim_buf_get_name(0)), {
        loclist = 0,
        on_exit = function(obj, args, qfid)
          local function cleanup()
            clear_conflict_markers_autocmd()

            -- print("id", vim.inspect(id)) -- TODO debug
            if id then
              qflist = vim.fn.getloclist(0, { id = 0 })

              if id == qflist.id then
                vim.cmd.lclose()
                vim.fn.setloclist(0, {}, "u", { items = {}, title = title })
              end
            end
          end

          if obj.code == 0 then
            id = qfid
            update_context(vim.b[bufnr].changedtick)
          elseif obj.code == 1 then
            cleanup()
            vim.notify("No conflict markers found.")
          elseif obj.code > 1 then
            cleanup()
            vim.notify(string.format(
              "Error searching for “%s”. Unmatched quotes? Check your command.", args
            ))
          end
        end,
        title = title,
      }
    )
  end

  update_conflict_markers()
  clear_conflict_markers_autocmd()

  vim.api.nvim_create_augroup("conflict_markers", { clear = false })

  conflict_marker_autocmd = vim.api.nvim_create_autocmd({ "BufWritePost", "WinEnter" }, {
    group = conflict_markers,
    buffer = bufnr,
    callback = function(args)
      local bufnr = args.buf

      if vim.api.nvim_get_current_buf() ~= bufnr then
        -- After a BufWritePost do nothing if bufnr is not current
        return
      end

      if not id then
        -- Job has not exited, no loclist id, no context
        return
      end

      if vim.fn.getloclist(0, { id = 0 }).id == id then
        local loclist = vim.fn.getloclist(0, { context = 1, id = 0, items = 1 }) -- TODO items
        -- print("loclist", vim.inspect(loclist)) -- TODO debug

        if loclist.context.conflict_markers.changedtick < vim.b.changedtick then
          update_context(vim.b.changedtick)
          update_conflict_markers()
        end
      end
    end,
  })
end, { nargs = 0 })
