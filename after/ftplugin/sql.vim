function! s:SQL_statusline()
    " vim-dadbod
    if exists("b:db")
        let b:Statusline_custom_rightline = "%9*dadbod%*"
        let b:Statusline_custom_mod_rightline = "%9*dadbod%*"
        call statusline#RedefineStatusLine()
    endif
endfunction

autocmd BufWinEnter <buffer> call s:SQL_statusline()
