command! -nargs=0 StatusLineInitialize call statusline#initialize()

" Autocommands

" Setting a default not current statusline
" margins of 1 column (on both sides)
let &statusline=" %f "

augroup Statusline
    autocmd!
    " TODO redrawstatus should work here, create an issue on github
    autocmd CmdlineEnter : call statusline#HighlightMode('command') | redraw
    autocmd CmdlineEnter /,\? call statusline#HighlightMode('search') | redraw
    autocmd ColorScheme * call statusline#initialize()
    autocmd DiagnosticChanged * call statusline#RedefineStatusLine()
    autocmd InsertEnter * call statusline#HighlightMode('insert')
    autocmd ModeChanged [^vV\x16]:[vV\x16]* call statusline#HighlightMode('visual')
    autocmd ModeChanged [^n]*:n* call statusline#HighlightMode('normal')
    autocmd TermEnter * call statusline#HighlightMode('terminal')
    autocmd TermEnter * call statusline#DefineTerminalStatusLine()
    autocmd TermLeave * call statusline#RedefineStatusLine()
    autocmd User CustomStatusline call statusline#RedefineStatusLine()
    autocmd VimEnter * autocmd Statusline
                \ BufWinEnter,BufWritePost,TextChanged,TextChangedI,WinEnter *
                \ call statusline#RedefineStatusLine()
    autocmd VimEnter * autocmd Statusline
                \ WinLeave * call statusline#DefineStatusLineNoFocus()
    autocmd VimEnter * call statusline#initialize()
    autocmd VimEnter * call statusline#RedefineStatusLine()
augroup END
if v:vim_did_enter
    doautocmd Statusline VimEnter
endif

" vim: fdm=marker
