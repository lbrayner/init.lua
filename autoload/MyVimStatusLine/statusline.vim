let s:left_status_cmd = "expand('%')"

function! MyVimStatusLine#statusline#DefaultLeftStatusLine()
    let left_status_cmd = s:left_status_cmd
    if exists("b:MVSL_left_status_cmd")
        let left_status_cmd = b:MVSL_left_status_cmd
    endif
    exec "let status_line = ".left_status_cmd
    return status_line
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
    set statusline=%<%{MyVimStatusLine#statusline#DefaultLeftStatusLine()}%=
    set statusline+=\ %1*%{&ft}%*
    set statusline+=\ #%n
    set statusline+=\ %2*%1.(%{MyVimStatusLine#statusline#DefaultReadOnlyFlag()}%)%*
    set statusline+=\ %2*%1.(%{MyVimStatusLine#statusline#DefaultModifiedFlag()}%)%*
    set statusline+=\ %4.(%3*%{&fileformat}%*%)
    set statusline+=\ :%2.c\ %3*%L%*\ %3.P
    set statusline+=\ %3*%{&fileencoding}%*
endfunction
