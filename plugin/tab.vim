augroup LastTabAutoGroup
    autocmd!
    autocmd TabLeave * if exists("g:tab#lastTab")
                \| let g:tab#beforeLastTab = g:tab#lastTab
                \| endif
                \| let g:tab#lastTab = tabpagenr()
augroup END

augroup TabCloseAutoGroup
    autocmd!
    autocmd TabClosed * if exists("g:tab#lastTab")
                \| let g:tab#lastTab = g:tab#beforeLastTab
                \| endif
                \| if g:tab#beforeLastTab != g:tab#lastTab
                \| call tab#GoToLastTab() " Tab closed was the current tab
                \| endif
augroup END

function! s:DoTabEqualizeWindows()
    call tab#TabDo("res 1000 | normal! \<c-w>=")
endfunction

command! TabEqualizeWindows call s:DoTabEqualizeWindows()
command! -bang TabCloseRight call tab#TabCloseRight('<bang>')
command! -bang TabCloseLeft call tab#TabCloseLeft('<bang>')

augroup TabActionsOnVimEnter
    autocmd!
    autocmd VimEnter * call s:DoTabEqualizeWindows()
augroup END

if exists("*gettabinfo")
    map <Plug>GoToTab :call tab#GoToTab()<cr>
    nmap <silent> <F8> <Plug>GoToTab
else
    nmap <silent> <F8> :tabs<cr>
endif

nnoremap <silent> <Leader><f8> :call tab#GoToLastTab()<cr>
