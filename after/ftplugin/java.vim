" Only do this when not done yet for this buffer
if exists("b:MVGoodies_did_ftplugin")
    finish
endif
let b:did_ftplugin = 1

if &ft == 'java'
    augroup MVGoodies_BE_java
        autocmd! BufEnter <buffer>
        autocmd  BufEnter <buffer>
            \ nnoremap <buffer> <leader>P :echo eclim#java#util#GetPackage()<cr>
    augroup END
endif
