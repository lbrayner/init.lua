local winhighlight_store = {}

local function save_winhighlight(winid)
  winhighlight_store[winid] = vim.wo[winid].winhighlight
end

local function restore_winhighlight(winid)
  vim.wo[winid].winhighlight = winhighlight_store[winid]
end

local function flash_window(winid)
  if winid == 0 then
    winid = vim.api.nvim_get_current_win()
  end

  save_winhighlight(winid)

  local timer = vim.loop.new_timer()
  local i = 0

  timer:start(0, 100, vim.schedule_wrap(function()
    if vim.api.nvim_get_current_win() ~= winid then
      timer:close()
      return restore_winhighlight(winid)
    end
    if i % 2 == 0 then
      vim.api.nvim_win_call(winid, function()
        vim.opt.winhighlight:append({ ["Normal"]="DiffAdd" })
        -- print("append " .. vim.wo[winid].winhighlight) -- TODO remove
      end)
    else
      vim.api.nvim_win_call(winid, function()
        vim.opt.winhighlight:remove({ "Normal" })
        -- print("remove " .. vim.wo[winid].winhighlight) -- TODO remove
      end)
    end
    if i > 2 then
      timer:close()
      return restore_winhighlight(winid)
    end
    i = i + 1
  end))
end

-- vim.api.nvim_create_user_command("FlashWindowMode", function(command)
-- end, { nargs=0 })

for _, mode in ipairs({ "", -- nvo: normal, visual, operator-pending
  "i" }) do
  vim.keymap.set(mode, "<F10>", function() flash_window(0) end)
end
