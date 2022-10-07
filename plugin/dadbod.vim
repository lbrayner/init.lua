" SQL_SelectParagraph

function! s:Do_SQL_SelectParagraph()
    exe "normal! vip:DB\<cr>"
endfunction

function! s:SQL_SelectParagraph()
    call util#PreserveViewPort(funcref("<SID>Do_SQL_SelectParagraph"))
endfunction

nnoremap <silent> <Leader><Return> :call <SID>SQL_SelectParagraph()<cr>
nnoremap <silent> <Leader><kEnter> :call <SID>SQL_SelectParagraph()<cr>
