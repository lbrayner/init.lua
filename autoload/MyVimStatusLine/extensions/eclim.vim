function! MyVimStatusLine#extensions#eclim#EclimLoaded()
    return exists(':ProjectCreate')
endfunction

function! MyVimStatusLine#extensions#eclim#EclimAvailable()
    return eclim#EclimAvailable(0)
endfunction

function! MyVimStatusLine#extensions#eclim#CurrentProjectName()
    let eclimAvailable = MyVimStatusLine#extensions#eclim#EclimAvailable()
    if eclimAvailable
        return eclim#project#util#GetCurrentProjectName()
    endif
    return ""
endfunction

function! MyVimStatusLine#extensions#eclim#WarningFlag()
    let bufnr = bufnr("%")
    redir => output
        silent! execute "sign place buffer=".bufnr
    redir END

    let lines = split(output, '\n')

    if len(lines) >= 3
        " echomsg lines[2]
        let first_sign_line = lines[2]
        let type = substitute(first_sign_line,".*name=\\(\\w\\+\\)$","\\1","")
        if type ==? 'error'
            let warning_flag = 'E'
        else
            let warning_flag = 'W'
        endif
    else
        let warning_flag = ''
    endif

    return warning_flag
endfunction

function MyVimStatusLine#extensions#eclim#DefineEclimStatusLine()
    set statusline=%<%{MyVimStatusLine#statusline#DefaultLeftStatusLine()}%=
    set statusline+=\ %2*%{MyVimStatusLine#extensions#eclim#WarningFlag()}%*
    set statusline+=\ %4*%.20{MyVimStatusLine#extensions#eclim#CurrentProjectName()}%*
    set statusline+=\ %1*%{&ft}%*
    set statusline+=\ #%n
    set statusline+=\ %2*%1.(%{MyVimStatusLine#statusline#DefaultReadOnlyFlag()}%)%*
    set statusline+=%2*%1.(%{MyVimStatusLine#statusline#DefaultModifiedFlag()}%)%*
    set statusline+=\ %4.(%3*%{&fileformat}%*%)
    set statusline+=\ :%2.c\ %3*%L%*\ %3.P
    set statusline+=\ %3*%{&fileencoding}%*
endfunction
