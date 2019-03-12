function! DBextPostResult(...)
    " removing an undesirable mapping
    unmap <buffer> q
    if b:dbext_type ==# "MYSQL"
        if b:dbext_extra =~# "vvv"
            syn region ResultFold start="^--------------$" end="^--------------$"
                        \ keepend transparent fold
            syn sync fromstart
            setlocal foldmethod=syntax
            normal! 2j
        endif
    endif
    setlocal nomodifiable
    setlocal nomodified
endfunction

function! s:SQL_SelectParagraph()
    let winview = winsaveview()
    exe "normal! vip:\<c-u>call dbext#DB_execSql(DB_getVisualBlock())\<cr>"
    call winrestview(winview)
endfunction

let s:toggle_window_size = 0
let s:result_window_small_size = 10

function! s:ToggleSizeOrOpenResults()
    let last_winnr = winnr()
    call dbext#DB_windowOpen()
    " dbext code sets modified
    if !&modifiable
        set nomodified
    endif
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

nnoremap <silent> <leader><return> :call <SID>SQL_SelectParagraph()<cr>
nnoremap <silent> <F11> :call <SID>ToggleSizeOrOpenResults()<cr>
