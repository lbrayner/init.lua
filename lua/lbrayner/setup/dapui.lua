local join = require("lbrayner").join

require("dapui").setup({
  layouts = {
    {
      -- You can change the order of elements in the sidebar
      elements = {
        -- Provide IDs as strings or tables with "id" and "size" keys
        {
          id = "scopes",
          size = 0.25, -- Can be float or integer > 1
        },
        { id = "breakpoints", size = 0.25 },
        { id = "stacks", size = 0.25 },
        { id = "watches", size = 0.25 },
      },
      size = 40,
      position = "left", -- Can be "left" or "right"
    },
    {
      elements = {
        "repl",
        "console",
      },
      size = 10,
      position = "bottom", -- Can be "bottom" or "top"
    },
    {
      elements = {
        "console",
      },
      size = 10,
      position = "bottom", -- Can be "bottom" or "top"
    },
  },
})

vim.api.nvim_create_user_command("DapUiClose", function(opts)
  require("dapui").close({ layout = tonumber(opts.args) })
end, { nargs = "?" })

vim.api.nvim_create_user_command("DapUiOpen", function(opts)
  require("dapui").open({ layout = tonumber(opts.args) })
end, { nargs = "?" })

vim.api.nvim_create_user_command("DapUiToggle", function(opts)
  local fargs = opts.fargs
  local reset = false

  if fargs[1] == "--reset" then
    reset = true
    fargs = #fargs > 1 and vim.list_slice(fargs, 2, #fargs) or {}
  end

  assert(
    vim.tbl_isempty(fargs) or #fargs == 1,
    string.format("Illegal arguments: %s", join(opts.fargs))
  )

  local layout = tonumber(fargs[1])

  assert(
    vim.tbl_isempty(fargs) or type(layout) == "number",
    string.format(
      "Illegal arguments: %s. OpenArgs.layout must be a number.",
      join(opts.fargs)
    )
  )

  require("dapui").toggle({ layout = layout, reset = reset })
end,
{
  complete = function(_, cmdline)
    local fargs = vim.iter(string.gmatch(cmdline, "%s+(%S+)")):totable()

    if vim.tbl_isempty(fargs) or
      #fargs == 1 and fargs[1] ~= "--reset" and ("--reset"):find("^" .. fargs[1]) then
      return { "--reset" }
    end
  end,
  nargs = "*",
})
