function! s:DatabaseAccess()
    nnoremap <buffer> <Leader><Return> :call database#select_paragraph()<CR>
    nnoremap <buffer> <Leader><kEnter> :call database#select_paragraph()<CR>

    function! s:DatabaseAccessClear()
        unlet! b:Statusline_custom_rightline
        unlet! b:Statusline_custom_mod_rightline
        silent! nunmap <buffer> <Leader>sdt
        call statusline#RedefineStatusLine()
        " vim-dadbod
        unlet! b:db
    endfunction

    command! -buffer -nargs=0 DatabaseAccessClear call s:DatabaseAccessClear()
endfunction

augroup DatabaseAccess
    autocmd!
    autocmd FileType redis,sql
                \ autocmd! DatabaseAccess BufEnter <buffer> ++once call s:DatabaseAccess()
augroup END
