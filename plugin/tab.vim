function! s:DoTabEqualizeWindows()
    call tab#TabDo("normal! \<C-W>=")
endfunction

command! -nargs=0 TabEqualizeWindows call s:DoTabEqualizeWindows()
command! -nargs=0 -bang TabcloseRight call tab#TabcloseRight("<bang>")
command! -nargs=0 -bang TabcloseLeft call tab#TabcloseLeft("<bang>")
command! -nargs=0 -bang Tabonly call tab#Tabonly("<bang>")
command! -nargs=0 -bang Tabclose call tab#Tabclose("<bang>")
command! -nargs=+ -bang TabcloseRange call tab#TabcloseRange("<bang>", <f-args>)
command! -nargs=0 Tabnew call util#PreserveViewPort("tabe %")
command! -nargs=0 Tabedit Tabnew

augroup TabActionsOnVimEnter
    autocmd!
    autocmd VimEnter * if v:this_session != "" | call s:DoTabEqualizeWindows() | endif
augroup END
