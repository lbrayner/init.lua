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
    if ! exists("b:MVSL_warning_flag")
        return ""
    endif
    return b:MVSL_warning_flag
endfunction

function! MyVimStatusLine#extensions#eclim#LoadWarningFlag()
    let b:MVSL_warning_flag = s:GetWarningFlag()
endfunction

function! s:GetWarningFlag()
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
