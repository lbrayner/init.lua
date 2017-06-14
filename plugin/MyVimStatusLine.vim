augroup MyVimStatusLineInsertEnterLeave
    autocmd! InsertEnter * call MyVimStatusLine#HighlightMode('insert')
    autocmd! InsertLeave * call MyVimStatusLine#HighlightMode('normal')
augroup END

noremap <Plug>HighlightStatusLineNC  :call MyVimStatusLine#HighlightStatusLineNC()<CR>

if !exists(":HighlightStatusLineNC")
    command -nargs=0  HighlightStatusLineNC  :call s:HighlightStatusLineNC()
endif
