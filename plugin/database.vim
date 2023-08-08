function! s:DatabaseAccess()
    nnoremap <buffer> <Leader><Return> <Cmd>'{,'}DB<CR>
    nnoremap <buffer> <Leader><kEnter> <Cmd>'{,'}DB<CR>

    " vim-dadbod
    if exists("b:db")
        let b:Statusline_custom_rightline = "%9*dadbod%* "
        let b:Statusline_custom_mod_rightline = "%9*dadbod%* "
    endif

    function! s:DatabaseAccessClear()
        " postgresql
        silent! nunmap <buffer> <Leader>dt
        " vim-dadbod
        unlet! b:db
        " statusline
        unlet! b:Statusline_custom_rightline
        unlet! b:Statusline_custom_mod_rightline
        silent! doautocmd <nomodeline> User CustomStatusline
    endfunction

    command! -buffer -nargs=0 DatabaseAccessClear call s:DatabaseAccessClear()
endfunction

augroup DatabaseAccess
    autocmd!
    autocmd FileType redis,sql
                \ autocmd! DatabaseAccess BufEnter <buffer> ++once call s:DatabaseAccess()
augroup END

function! s:SQLDatabaseAccess()
    " vim-dadbod
    if exists("b:db")
        if stridx(b:db, "postgresql") == 0
            " Describe this object
            nnoremap <buffer> <Leader>dt <Cmd>exe "DB \\d " . expand("<cWORD>")<CR>
            return
        endif
    endif
endfunction

augroup SQLDatabaseAccess
    autocmd!
    autocmd FileType sql
                \ autocmd! SQLDatabaseAccess BufEnter <buffer> ++once call s:SQLDatabaseAccess()
augroup END
