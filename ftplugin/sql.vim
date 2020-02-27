if exists("b:my_did_ftplugin")
    finish
endif
let b:my_did_ftplugin = 1

nnoremap <buffer> <silent> <F11> :call DBextToggleSizeOrOpenResults()<cr>

" Command Declarations
command! -buffer SqlBreakString
            \ :call append(line("."),sql#format#break_string(getline("."))) | delete

" delimitMate

let b:delimitMate_matchpairs = "(:),[:],{:}"

" vim-surround

let b:surround_indent = 0
