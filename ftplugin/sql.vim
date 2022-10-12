if exists("b:my_did_ftplugin")
    finish
endif
let b:my_did_ftplugin = 1

" Command Declarations
command! -buffer SqlBreakString
            \ :call append(line("."),sql#format#break_string(getline("."))) | delete

" delimitMate

let b:delimitMate_matchpairs = "(:),[:],{:}"

" vim-surround

let b:surround_indent = 0

" database access

nnoremap <buffer> <Leader><Return> :call database#select_paragraph()<cr>
nnoremap <buffer> <Leader><kEnter> :call database#select_paragraph()<cr>
