function! MyVimStatusLine#statusline#DefaultLeftStatusLine()
    return expand('%')
endfunction

function! MyVimStatusLine#statusline#DefaultReadOnlyFlag()
    if &readonly
        return 'R'
    endif
    return ''
endfunction

function! MyVimStatusLine#statusline#DefaultModifiedFlag()
    if &modified
        return '*'
    endif
    if !&modifiable
        return '-'
    endif
    return ''
endfunction

function MyVimStatusLine#statusline#DefineDefaultStatusLine()
    set statusline=%<%{MyVimStatusLine#statusline#DefaultLeftStatusLine()}%=\ %1*%y%*
    set statusline+=\ #%n
    set statusline+=\ %2*%1.(%{MyVimStatusLine#statusline#DefaultReadOnlyFlag()}%)%*
    set statusline+=\ %2*%1.(%{MyVimStatusLine#statusline#DefaultModifiedFlag()}%)%*
    set statusline+=\ %4.(%3*%{&fileformat}%*%)
    set statusline+=\ :%2.c\ %3*%L%*\ %3.P
    set statusline+=\ %3*%{&fileencoding}%*
endfunction
