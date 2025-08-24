-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#lua_ls
return {
  settings = {
    Lua = {
      runtime = {
        path = {
          "lua/?.lua",
          "lua/?/init.lua",
        },
        -- Tell the language server which version of Lua you"re using (most
        -- likely LuaJIT in the case of Neovim)
        version = "LuaJIT",
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = { "vim" },
      },
      workspace = {
        checkThirdParty = false,
        -- Make the server aware of Neovim runtime files
        library = vim.env.VIMRUNTIME,
      },
      -- Do not send telemetry data containing a randomized but unique
      -- identifier
      telemetry = {
        enable = false,
      },
    },
  },
}
