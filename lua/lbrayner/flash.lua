local winid = vim.api.nvim_get_current_win()
local timer = vim.loop.new_timer()
local i = 0
-- Waits 1000ms, then repeats every 750ms until timer:close().
timer:start(0, 100, vim.schedule_wrap(function()
  if i % 2 == 0 then
    -- vim.cmd("set winhighlight=Normal:NormalNC")
    vim.api.nvim_win_call(winid, function()
      vim.opt.winhighlight:append({ ["Normal"]="DiffAdd" })
      print("append " .. vim.wo[winid].winhighlight)
    end)
  else
    -- vim.cmd("set winhighlight=")
    vim.api.nvim_win_call(winid, function()
      vim.opt.winhighlight:remove({ "Normal" })
      print("remove " .. vim.wo[winid].winhighlight)
    end)
  end
  if i > 24 then
    timer:close()  -- Always close handles to avoid leaks.
  end
  i = i + 1
end))
