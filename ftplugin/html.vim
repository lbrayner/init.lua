if exists("b:my_did_ftplugin")
    finish
endif
let b:my_did_ftplugin = 1

if &ft == 'html'
    vmap <buffer> <leader>a <Plug>Linkify
endif
