local function flash_window(winid)
  if winid == 0 then
    winid = vim.api.nvim_get_current_win()
  end

  local timer = vim.loop.new_timer()
  local i = 0

  timer:start(0, 100, vim.schedule_wrap(function()
    if i % 2 == 0 then
      vim.api.nvim_win_call(winid, function()
        vim.opt.winhighlight:append({ ["Normal"]="DiffAdd" })
        print("append " .. vim.wo[winid].winhighlight) -- TODO remove
      end)
    else
      vim.api.nvim_win_call(winid, function()
        vim.opt.winhighlight:remove({ "Normal" })
        print("remove " .. vim.wo[winid].winhighlight) -- TODO remove
      end)
    end
    if i > 24 then
      timer:close()
    end
    i = i + 1
  end))
end

return {
  flash_window = flash_window,
}
