function! TrailingWhitespaceGroup()
    highlight TrailingWhitespace ctermbg=red ctermfg=white guibg=#ff0000
endfunction

call TrailingWhitespaceGroup()

function! HighlightTrailingWhitespace()
    if &syntax =~# '\v(help|netrw)'
        call ClearTrailingWhitespace()
        return
    endif
    if &syntax =~# '\v(mail|markdown)'
        call ClearTrailingWhitespace()
        let w:TrailingWhitespaceID = matchadd("TrailingWhitespace",'^\s\+$')
        return
    endif
    if &syntax ==# "git"
        call ClearTrailingWhitespace()
        let w:TrailingWhitespaceID = matchadd("TrailingWhitespace",
                    \'^\%( \{4}\zs\s\+\|[| ]\+| \{5}\zs\s\+\)$')
        return
    endif
    call ClearTrailingWhitespace()
    let w:TrailingWhitespaceID = matchadd("TrailingWhitespace",'\s\+$')
endfunction

function! ClearTrailingWhitespace()
    if exists("w:TrailingWhitespaceID")
        silent! call matchdelete(w:TrailingWhitespaceID)
        unlet w:TrailingWhitespaceID
    endif
endfunction

augroup HighlightAndMatch
    autocmd!
    autocmd ColorScheme * call TrailingWhitespaceGroup()
    autocmd BufWinLeave * call ClearTrailingWhitespace()
    " BufWinEnter covers all windows on startup (think of sessions)
    autocmd BufWinEnter * call HighlightTrailingWhitespace()
    " But it becomes insufficient and redundant after that
    autocmd VimEnter * autocmd! HighlightAndMatch BufWinEnter
    autocmd VimEnter * autocmd HighlightAndMatch
                \ WinEnter,Syntax * call HighlightTrailingWhitespace()
    autocmd VimEnter * call HighlightTrailingWhitespace()
augroup END