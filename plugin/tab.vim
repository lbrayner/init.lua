augroup LastTabAutoGroup
    autocmd!
    au TabLeave * if exists("g:tab#lastTab")
                \| let g:tab#beforeLastTab = g:tab#lastTab
                \| endif
                \| let g:tab#lastTab = tabpagenr()
augroup END

augroup TabCloseAutoGroup
    autocmd!
    autocmd TabClosed * if exists("g:tab#lastTab")
                \| let g:tab#lastTab = g:tab#beforeLastTab
                \| endif
                \| call tab#GoToLastTab()
augroup END

function! s:DoTabEqualizeWindows()
    call tab#TabDo("res 1000 | normal! \<c-w>=")
endfunction

command! TabEqualizeWindows call s:DoTabEqualizeWindows()
command! -bang TabCloseRight call tab#TabCloseRight('<bang>')
command! -bang TabCloseLeft call tab#TabCloseLeft('<bang>')

augroup TabActionsOnVimEnter
    autocmd!
    au VimEnter * call s:DoTabEqualizeWindows()
augroup END

if exists("*gettabinfo")
    map <Plug>GoToTab :call tab#GoToTab()<cr>
    nmap <silent> <F8> <Plug>GoToTab
else
    nmap <silent> <F8> :tabs<cr>
endif

nmap <silent> <Leader><f8> :call tab#GoToLastTab()<cr>
