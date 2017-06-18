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

let s:status_line_tail = ' %1*%{&ft}%*'
                     \ . ' #%n'
                     \ . ' %2*%1.(%{MyVimStatusLine#statusline#DefaultReadOnlyFlag()}%)%*'
                     \ .  '%2*%1.(%{MyVimStatusLine#statusline#DefaultModifiedFlag()}%)%*'
                     \ . ' %4.(%3*%{&fileformat}%*%)'
                     \ . ' :%2.c %3*%L%* %3.P'
                     \ . ' %3*%{&fileencoding}%*'

function! MyVimStatusLine#statusline#GetStatusLineTail()
    return s:status_line_tail
endfunction

function MyVimStatusLine#statusline#DefineStatusLine()
    set statusline=%<%f%=
    exec "let &statusline='".&statusline.s:status_line_tail."'"
endfunction
