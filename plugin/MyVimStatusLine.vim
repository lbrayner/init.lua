set statusline=%<%f%=\ %1*%y%*
set statusline+=\ %4.(#%n%)
set statusline+=\ %2*%2.(%R%)\ %3.(%m%)%*
set statusline+=\ %4.(%3*%{&fileformat}%*%)
set statusline+=\ %4.l:%4.(%c%V%)\ %4*%L%*\ %3.P
set statusline+=\ %5*%{&fileencoding}%*

call MyVimStatusLine#initialize()

augroup MyVimStatusLineInsertEnterLeave
    autocmd! InsertEnter * call MyVimStatusLine#HighlightMode('insert')
    autocmd! InsertLeave * call MyVimStatusLine#HighlightMode('normal')
augroup END

noremap <Plug>HighlightStatusLineNC  :call MyVimStatusLine#HighlightStatusLineNC()<CR>

if !exists(":HighlightStatusLineNC")
    command -nargs=0  HighlightStatusLineNC  :call s:HighlightStatusLineNC()
endif

call MyVimStatusLine#HighlightMode('normal')
call MyVimStatusLine#HighlightStatusLineNC()
