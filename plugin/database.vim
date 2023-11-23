" Backend is vim-dadbod

function! s:DatabaseAccess()
    nnoremap <buffer> <C-Return> <Cmd>'{,'}DB<CR>
    nnoremap <buffer> <C-kEnter> <Cmd>'{,'}DB<CR>

    if exists("b:db")
        let b:Statusline_custom_rightline = "%9*dadbod%* "
        let b:Statusline_custom_mod_rightline = "%9*dadbod%* "
    endif

    function! s:DatabaseAccessClear()
        unlet! b:db
        " postgresql
        silent! nunmap <buffer> <Leader>dt
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
    autocmd FileType sql autocmd! SQLDatabaseAccess BufEnter <buffer> ++once call s:SQLDatabaseAccess()
augroup END

function! s:Postgres(name)
    let b:db = substitute(a:name, '\v^postgresql:(.*)\@.*:(\d+)\.sql$', 'postgresql://\1@localhost:\2', "")
endfunction

function! s:Redis(name)
    let b:db = substitute(a:name, '\v^redis:.*:(\d+)\.redis$', 'redis://:\1', "")
endfunction

augroup DatabaseConnection
    autocmd!
    autocmd BufRead postgresql:*@*:*.sql call s:Postgres(fnamemodify(expand("<amatch>"), ":t"))
    autocmd BufRead redis:*:*.redis call s:Redis(fnamemodify(expand("<amatch>"), ":t"))
augroup END
