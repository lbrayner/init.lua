function! s:OverlengthToggle()
    if !exists("w:Overlength")
        let w:Overlength = 90
    endif
    let matches = filter(getmatches(), "v:val.group == 'Overlength'")
    if !empty(matches)
        for matchd in matches
            call matchdelete(matchd.id)
        endfor
        echo "Overlength highlight cleared."
        return
    endif
    highlight Overlength ctermbg=red ctermfg=white guibg=#592929
    call matchadd("Overlength",'\%'.w:Overlength.'v.\+')
    echo "Overlength highlighted."
endfunction

command! -nargs=0 OverlengthToggle call s:OverlengthToggle()

function! TrailingWhitespaceGroup()
    highlight TrailingWhitespace ctermbg=red ctermfg=white guibg=#ff0000
endfunction

call TrailingWhitespaceGroup()

function! HighlightTrailingWhitespace()
    if &buftype == "terminal"
        call ClearTrailingWhitespace()
        return
    endif
    if &syntax =~# '\v%(help|netrw)'
        call ClearTrailingWhitespace()
        return
    endif
    if &syntax =~# '\v%(mail|markdown)'
        call ClearTrailingWhitespace()
        call matchadd("TrailingWhitespace",'^\s\+$')
        return
    endif
    if &syntax ==# "git"
        call ClearTrailingWhitespace()
        " Commit message paragraphs
        " Git branch graphs
        " Diffs
        call matchadd("TrailingWhitespace", '^\%( \{4}\zs\s\+\|[| ]\+| \{5}\zs\s\+\|[+-].*[^ 	]\+\zs\s\+\)$')
        return
    endif
    " Neogit
    if stridx(&syntax,"Neogit") == 0
        call ClearTrailingWhitespace()
        return
    endif
    " Telescope
    if &syntax =~# '\v%(TelescopePrompt|TelescopeResults)'
        call ClearTrailingWhitespace()
        return
    endif
    call ClearTrailingWhitespace()
    call matchadd("TrailingWhitespace",'\s\+$')
endfunction

function! ClearTrailingWhitespace()
    let matches = filter(getmatches(), "v:val.group == 'TrailingWhitespace'")
    if !empty(matches)
        for matchd in matches
            call matchdelete(matchd.id)
        endfor
    endif
endfunction

augroup HighlightTrailingWhitespace
    autocmd!
    autocmd ColorScheme * call TrailingWhitespaceGroup()
    " BufWinEnter covers all windows on startup (think of sessions)
    autocmd BufWinEnter * call HighlightTrailingWhitespace()
    autocmd VimEnter * autocmd HighlightTrailingWhitespace
                \ WinEnter,Syntax * call HighlightTrailingWhitespace()
    autocmd VimEnter * autocmd HighlightTrailingWhitespace
                \ TermOpen * call HighlightTrailingWhitespace()
    autocmd VimEnter * call HighlightTrailingWhitespace()
augroup END
if v:vim_did_enter
    doautocmd HighlightTrailingWhitespace VimEnter
endif
