local winhighlight_store = {}

local function save_winhighlight(winid)
  winhighlight_store[winid] = vim.wo[winid].winhighlight
end

local function restore_winhighlight(winid)
  vim.wo[winid].winhighlight = winhighlight_store[winid]
end

local function flash_window()
  local winid = vim.api.nvim_get_current_win()

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
      end)
    else
      vim.api.nvim_win_call(winid, function()
        vim.opt.winhighlight:remove({ "Normal" })
      end)
    end
    if i > 2 then
      timer:close()
      return restore_winhighlight(winid)
    end
    i = i + 1
  end))
end

local flash_window_mode

vim.api.nvim_create_user_command("FlashWindowMode", function()
  if flash_window_mode then
    vim.api.nvim_del_augroup_by_id(flash_window_mode)
    flash_window_mode = nil
    return print("Flash window mode disabled.")
  end
  flash_window_mode = vim.api.nvim_create_augroup("flash_window_mode", { clear=true })
  vim.api.nvim_create_autocmd("WinEnter", {
    group = flash_window_mode,
    desc = "Flash window mode",
    callback = flash_window,
  })
  flash_window()
  print("Flash window mode enabled.")
end, { nargs=0 })

for _, mode in ipairs({ "", -- nvo: normal, visual, operator-pending
  "i" }) do
  vim.keymap.set(mode, "<F10>", flash_window)
end
