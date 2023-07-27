if vim.fn.exists("#flash_window_mode") == 1 then
  vim.api.nvim_del_augroup_by_name("flash_window_mode")
end

local winhighlight_store = {}

local function save_winhighlight(winid)
  winhighlight_store[winid] = vim.wo[winid].winhighlight
end

local function restore_winhighlight(winid)
  if vim.api.nvim_win_is_valid(winid) then
    vim.wo[winid].winhighlight = winhighlight_store[winid]
  end
  winhighlight_store[winid] = nil
end

local function flash_window()
  local winid = vim.api.nvim_get_current_win()

  save_winhighlight(winid)

  local timer = vim.uv.new_timer()
  local mod = 2
  local i = 0

  timer:start(0, 100, vim.schedule_wrap(function()
    if vim.api.nvim_get_current_win() ~= winid then
      if not timer:is_closing() then
        timer:close()
      end
      restore_winhighlight(winid)
      return
    end
    if i % mod == 0 then
      vim.api.nvim_win_call(winid, function()
        vim.opt.winhighlight:append({ Normal = "DiffAdd" })
      end)
    else
      vim.api.nvim_win_call(winid, function()
        vim.opt.winhighlight:remove({ "Normal" })
      end)
    end
    if i > mod then
      if not timer:is_closing() then
        timer:close()
      end
      restore_winhighlight(winid)
      return
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
  flash_window_mode = vim.api.nvim_create_augroup("flash_window_mode", { clear = true })
  vim.api.nvim_create_autocmd("WinEnter", {
    group = flash_window_mode,
    desc = "Flash window mode",
    callback = flash_window,
  })
  flash_window()
  print("Flash window mode enabled.")
end, { nargs = 0 })

vim.keymap.set({
  "", -- nvo: normal, visual, operator-pending
  "i" }, "<F10>", flash_window)
