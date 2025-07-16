require("dapui").setup()

vim.api.nvim_create_user_command("DapUiClose", function(opts)
  require("dapui").close({ layout = tonumber(opts.args) })
end, { nargs = "?" })

vim.api.nvim_create_user_command("DapUiOpen", function(opts)
  require("dapui").open({ layout = tonumber(opts.args) })
end, { nargs = "?" })

vim.api.nvim_create_user_command("DapUiSetup", require("dapui").setup, { nargs = 0 })

vim.api.nvim_create_user_command("DapUiToggle", function(opts)
  local fargs = opts.fargs
  local reset = false

  if fargs[1] == "--reset" then
    reset = true
    fargs = #fargs > 1 and vim.list_slice(fargs, 2, #fargs) or {}
  end

  assert(
    vim.tbl_isempty(fargs) or #fargs == 1,
    string.format("Illegal arguments: %s", table.concat(opts.fargs, " "))
  )

  local layout = tonumber(fargs[1])

  assert(
    vim.tbl_isempty(fargs) or type(layout) == "number",
    string.format(
      "Illegal arguments: %s. OpenArgs.layout must be a number.",
      table.concat(opts.fargs, " ")
    )
  )

  require("dapui").toggle({ layout = tonumber(fargs[1]), reset = reset })
end,
{
  complete = function(arg_lead, cmdline, cursor_pos)
    local fargs = vim.iter(string.gmatch(cmdline, "%s+(%S+)")):totable()

    if vim.tbl_isempty(fargs) or
      #fargs == 1 and fargs[1] ~= "--reset" and ("--reset"):find("^" .. fargs[1]) then
      return { "--reset" }
    end
  end,
  nargs = "*",
})
