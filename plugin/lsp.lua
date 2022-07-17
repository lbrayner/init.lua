local util = require 'lspconfig.util'

require 'lspconfig'.tsserver.setup {
    root_dir = function(fname)
        return util.root_pattern 'tsconfig.json'(fname)
    end,
}
