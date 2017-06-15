function! MyVimStatusLine#statusline#DefaultLeftStatusLine()
    return expand('%')
endfunction

function MyVimStatusLine#statusline#DefineDefaultStatusLine()
    set statusline=%<%{MyVimStatusLine#statusline#DefaultLeftStatusLine()}%=\ %1*%y%*
    set statusline+=\ %4.(#%n%)
    set statusline+=\ %2*%2.R\ %1.M%*
    set statusline+=\ %4.(%3*%{&fileformat}%*%)
    set statusline+=\ %3.l:%2.c\ %3*%L%*\ %3.P
    set statusline+=\ %3*%{&fileencoding}%*
endfunction
