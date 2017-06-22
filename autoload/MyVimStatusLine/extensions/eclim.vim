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
    let warning_flag = ''
    let errorlist = eclim#display#signs#GetExisting('error')
    if len(errorlist) > 0
        let warning_flag = 'E'
    endif
    if warning_flag == ''
        let warninglist = eclim#display#signs#GetExisting()
        if len(warninglist) > 0
            let warning_flag = 'W'
        endif
    endif
    return warning_flag
endfunction
