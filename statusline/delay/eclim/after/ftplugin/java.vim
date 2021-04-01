if exists("b:Statusline_did_ftplugin")
    finish
endif
let b:Statusline_did_ftplugin = 1

function! s:StatusLine()
    let b:Statusline_custom_leftline = '%<%{expand("%:t:r")}'
                \ . ' %{statusline#StatusFlag()}'
    let b:Statusline_custom_rightline =
                \   ' %5*%.20{statusline#extensions#eclim#CurrentProjectName()}%*'
                \ . ' %3*%{statusline#extensions#eclim#WarningFlag()}%*'
                \ . statusline#GetStatusLineTail()
    let b:Statusline_custom_mod_leftline = '%<%1*%{expand("%:t:r")}'
                \ . ' %{statusline#StatusFlag()}%*'
    let b:Statusline_custom_mod_rightline =
                \   ' %5*%.20{statusline#extensions#eclim#CurrentProjectName()}%*'
                \ . ' %3*%{statusline#extensions#eclim#WarningFlag()}%*'
                \ . statusline#GetStatusLineTail()
endfunction

if &ft == 'java'
    if util#EclimLoaded()
        if extensions#eclim#EclimAvailable()
            let projectName = eclim#project#util#GetCurrentProjectName()
            if projectName != ""
                augroup Statusline_BWP_java
                    autocmd! BufWritePost <buffer>
                    autocmd  BufWritePost <buffer>
                                \ call statusline#extensions#eclim#LoadWarningFlag()
                augroup END
                " setting &l:path
                let &l:path=projectName.",".&path
                autocmd BufEnter <buffer> call s:StatusLine()
            endif
        endif
    endif
endif
