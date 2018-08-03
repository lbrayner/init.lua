augroup LastTabAutoGroup
    autocmd!
    au TabLeave * let g:tab#lasttab = tabpagenr()
augroup END

function! s:DoTabEqualizeWindows()
    call tab#TabDo("normal! \<c-w>=")
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
