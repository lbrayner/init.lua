let s:left_status_cmd = "expand('%')"

function! MyVimStatusLine#statusline#LeftAligned()
    let left_status_cmd = ""
    if exists("b:MVSL_left_status_cmd")
        let left_status_cmd = b:MVSL_left_status_cmd
    endif
    if left_status_cmd == ""
        if exists("s:left_status_cmd")
            let left_status_cmd = s:left_status_cmd
        else
            return ""
        endif
    endif
    exec "let status_line = ".left_status_cmd
    return status_line
endfunction

function! MyVimStatusLine#statusline#RightAligned()
    let right_status_cmd = ""
    if exists("b:MVSL_right_status_cmd")
        let right_status_cmd = b:MVSL_right_status_cmd
    endif
    if right_status_cmd == ""
        if exists("s:right_status_cmd")
            let right_status_cmd = s:right_status_cmd
        else
            return ""
        endif
    endif
    exec "let status_line = ".right_status_cmd
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

let MyVimStatusLine#statusline#status_line_tail = ' %1*%{&ft}%*'
                                              \ . ' #%n'
                                              \ . ' %2*%1.(%{MyVimStatusLine#statusline#DefaultReadOnlyFlag()}%)%*'
                                              \ . ' %2*%1.(%{MyVimStatusLine#statusline#DefaultModifiedFlag()}%)%*'
                                              \ . ' %4.(%3*%{&fileformat}%*%)'
                                              \ . ' :%2.c %3*%L%* %3.P'
                                              \ . ' %3*%{&fileencoding}%*'

function MyVimStatusLine#statusline#DefineStatusLine()
    set statusline=%<%{MyVimStatusLine#statusline#LeftAligned()}%=
    set statusline+=%{MyVimStatusLine#statusline#RightAligned()}
    set statusline+=\ %1*%{&ft}%*
    set statusline+=\ #%n
    set statusline+=\ %2*%1.(%{MyVimStatusLine#statusline#DefaultReadOnlyFlag()}%)%*
    set statusline+=%2*%1.(%{MyVimStatusLine#statusline#DefaultModifiedFlag()}%)%*
    set statusline+=\ %4.(%3*%{&fileformat}%*%)
    set statusline+=\ :%2.c\ %3*%L%*\ %3.P
    set statusline+=\ %3*%{&fileencoding}%*
endfunction
