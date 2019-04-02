" - Whether to use separate result buffers for each file
let g:dbext_default_use_sep_result_buffer = 1

function! DBextPostResult(...)
    " clearing buffer local mappings
    mapclear <buffer>
    nnoremap <buffer> <silent> C :call <SID>CloneResultBuffer()<cr>
    setlocal readonly
    setlocal nomodifiable
    setlocal nomodified
    if b:dbext_type ==# "PGSQL"
        if b:dbext_extra =~# "QUIET=off"
            syn region ResultFold start="\%2l" end="^SET$"
                        \ keepend transparent fold
            syn sync fromstart
            setlocal foldmethod=syntax
            normal! 2j
        endif
        return
    endif
    if b:dbext_type ==# "MYSQL"
        if b:dbext_extra =~# "vvv"
            syn region ResultFold start="^--------------$" end="^--------------$"
                        \ keepend transparent fold
            syn sync fromstart
            setlocal foldmethod=syntax
            normal! 2j
        endif
        return
    endif
endfunction

" SQL_SelectParagraph

function! s:Do_SQL_SelectParagraph()
    exe "normal! vip:\<c-u>call dbext#DB_execSql(DB_getVisualBlock())\<cr>"
endfunction

function! s:SQL_SelectParagraph()
    call util#PreserveViewPort(funcref("<SID>Do_SQL_SelectParagraph"))
endfunction

" ToggleSizeOrOpenResults

let s:toggle_window_size = 0
let s:result_window_small_size = 10

function! s:ToggleSizeOrOpenResults()
    let last_winnr = winnr()
    call dbext#DB_openResults()

    " dbext code sets modified
    setlocal readonly
    setlocal nomodifiable
    setlocal nomodified

    let current_winnr = winnr()
    if last_winnr != current_winnr
        return
    endif
    if s:toggle_window_size == 0
        exe "res " . (&lines - 20)
    endif
    if s:toggle_window_size == 1
        exe "res " . s:result_window_small_size
    endif
    let s:toggle_window_size = (s:toggle_window_size+1)%2
endfunction

function! s:CloneResultBuffer()
    let buf_nr = bufnr('%')
    let buf_name = bufname('%')
    silent! keepalt topleft 10 new
    setlocal modifiable
    setlocal noreadonly
    exec "file ".buf_name."-".util#random()
    silent! put =getbufline(buf_nr,1,'$')
    1d_
    setlocal readonly
    setlocal nomodified
    setlocal nomodifiable
    setlocal nowrap
    setlocal nonumber
    setlocal buftype=nofile
    setlocal bufhidden=wipe
    setlocal noswapfile
endfunction

nnoremap <silent> <leader><return> :call <SID>SQL_SelectParagraph()<cr>
nnoremap <silent> <F11> :call <SID>ToggleSizeOrOpenResults()<cr>
