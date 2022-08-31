function! s:StatusLine()
    let b:Statusline_custom_leftline = '%<%{expand("%:t:r")}'
                \ . ' %{statusline#StatusFlag()}'
    let b:Statusline_custom_rightline =
                \   '%9*%.20{statusline#extensions#eclim#CurrentProjectName()}%* '
                \ . '%1*%{statusline#extensions#eclim#WarningFlag()}%* '
    let b:Statusline_custom_mod_leftline = '%<%1*%{expand("%:t:r")}'
                \ . ' %{statusline#StatusFlag()}%*'
    let b:Statusline_custom_mod_rightline =
                \   '%9*%.20{statusline#extensions#eclim#CurrentProjectName()}%* '
                \ . '%1*%{statusline#extensions#eclim#WarningFlag()}%* '
endfunction

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
