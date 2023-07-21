local cmp = require("cmp")

local function cmp_visible(action)
  return function(fallback)
    if cmp.core.view:visible() then
      action()
    else
      fallback()
    end
  end
end

cmp.setup({
  completion = {
    autocomplete = false
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-B>"] = cmp.mapping.scroll_docs(-4),
    ["<C-F>"] = cmp.mapping.scroll_docs(4),
    ["<C-X><C-J>"] = cmp.mapping.complete(),
    ["<C-P>"] = cmp_visible(cmp.select_prev_item),
    ["<C-N>"] = cmp_visible(cmp.select_next_item),
    ["<C-G>"] = cmp.mapping.abort(),
    ["<C-Y>"] = cmp_visible(cmp.confirm),
  }),
  snippet = {
    expand = function(args)
      require("snippy").expand_snippet(args.body)
    end,
  },
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
  })
})
