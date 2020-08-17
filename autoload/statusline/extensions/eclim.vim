function! statusline#extensions#eclim#CurrentProjectName()
    let eclimAvailable = extensions#eclim#EclimAvailable()
    if eclimAvailable
        return eclim#project#util#GetCurrentProjectName()
    endif
    return ""
endfunction

function! statusline#extensions#eclim#WarningFlag()
    if ! exists("b:Statusline_warning_flag")
        return " "
    endif
    return b:Statusline_warning_flag
endfunction

function! statusline#extensions#eclim#LoadWarningFlag()
    let b:Statusline_warning_flag = s:GetWarningFlag()
endfunction

function! s:GetWarningFlag()
    let warning_flag = " "
    let errorlist = eclim#display#signs#GetExisting('error')
    if len(errorlist) > 0
        let warning_flag = "E"
    endif
    if warning_flag == " "
        let warninglist = eclim#display#signs#GetExisting()
        if len(warninglist) > 0
            let warning_flag = "W"
        endif
    endif
    return warning_flag
endfunction
