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

call util#vimmap('map','<Plug>GoToTab'
            \ ,':call tab#GoToTab()<cr>')
call util#vimmap('nmap <silent>','<F8>','<Plug>GoToTab')

call util#vimmap('nmap <silent>','<Leader><f8>'
            \ ,':call tab#GoToLastTab()<cr>')
