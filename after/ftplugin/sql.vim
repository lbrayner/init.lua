function! s:SQLDatabaseAccess()
    " vim-dadbod
    if exists("b:db")
        let b:Statusline_custom_rightline = "%9*dadbod%*"
        let b:Statusline_custom_mod_rightline = "%9*dadbod%*"
        if stridx(b:db, "postgresql") == 0
            " Describe this object
            nnoremap <buffer> <Leader>dt <Cmd>exe "DB \\d " . expand("<cWORD>")<CR>
            return
        endif
    endif
endfunction

autocmd BufEnter <buffer> ++once call s:SQLDatabaseAccess()
