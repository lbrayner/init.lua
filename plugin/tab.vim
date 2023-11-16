function! s:DoTabEqualizeWindows()
    call tab#TabDo("normal! \<C-W>=")
endfunction

command! -nargs=0 TabEqualizeWindows call s:DoTabEqualizeWindows()
command! -nargs=0 Tabnew call util#PreserveViewPort("tabe %")
command! -nargs=0 Tabedit Tabnew

augroup TabActionsOnVimEnter
    autocmd!
    autocmd VimEnter * if v:this_session != "" | call s:DoTabEqualizeWindows() | endif
augroup END
