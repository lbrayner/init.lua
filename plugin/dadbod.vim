" SQL_SelectParagraph

function! s:Do_SQL_SelectParagraph()
    exe "normal! vip:DB\<cr>"
endfunction

function! s:SQL_SelectParagraph()
    call util#PreserveViewPort(funcref("<SID>Do_SQL_SelectParagraph"))
endfunction

nnoremap <silent> <leader><return> :call <SID>SQL_SelectParagraph()<cr>
nnoremap <silent> <leader><kEnter> :call <SID>SQL_SelectParagraph()<cr>
