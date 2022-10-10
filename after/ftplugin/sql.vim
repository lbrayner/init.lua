function! s:SQLStatusLine()
    " vim-dadbod
    if exists("b:db")
        let b:Statusline_custom_rightline = "%9*dadbod%*"
        let b:Statusline_custom_mod_rightline = "%9*dadbod%*"
    endif
endfunction

augroup SQLStatusLine
    autocmd! SQLStatusLine * <buffer>
    autocmd BufWinEnter <buffer> call s:SQLStatusLine()
augroup END
