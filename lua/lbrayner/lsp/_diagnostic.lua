local M = {}

local diagnostic_qf_opts = {}

function M.diagnostic_setqflist(opts)
  opts = opts or {}
  opts.open = opts.open == nil and true or opts.open
  local clients = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })
  local diagnostics = {}

  for _, client in ipairs(clients) do
    diagnostic_qf_opts = vim.tbl_extend("keep", {
      namespace = vim.lsp.diagnostic.get_namespace(client.id),
    }, opts, diagnostic_qf_opts)

    vim.list_extend(diagnostics, vim.diagnostic.get(nil, diagnostic_qf_opts))
  end

  local names = vim.tbl_map(function (client)
    return client.name
  end, clients)

  table.sort(names)

  local title = "LSP Diagnostics: " .. table.concat(names, ",") -- joining items with a separator
  local severity = diagnostic_qf_opts.severity

  if severity then
    if type(severity) == "table" then severity = severity.min end
    title = string.format("%s (%s)", title, vim.diagnostic.severity[severity])
  end

  diagnostic_qf_opts.title = title

  local action = " "
  local items = vim.diagnostic.toqflist(diagnostics)
  local qflist = vim.fn.getqflist({ title = 1, winid = 1 })

  if qflist.title == title then
    action = "u"
  end

  vim.fn.setqflist({}, action, { title = title, items = items })

  if opts.open and qflist.winid == 0 then
    vim.cmd("botright copen")
  end
end

return M
