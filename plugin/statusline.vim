" vim: sw=4
function! s:OnVimEnter(...)
  call statusline#RedefineStatusLine()
endfunction

" From :h qf.vim:

" The quickfix filetype plugin includes configuration for displaying the command
" that produced the quickfix list in the status-line. To disable this setting,
" configure as follows:

let g:qf_disable_statusline = 1

set laststatus=3
set statusline=%{statusline#Empty()}
set winbar=%{%statusline#WinBar()%}

command! -nargs=0 StatusLineInitialize call statusline#initialize()

" Autocommands

augroup Statusline
    autocmd!
    " TODO redrawstatus should work here, create an issue on github
    autocmd CmdlineEnter : call statusline#HighlightMode("command") | redraw
    autocmd CmdlineEnter /,\? call statusline#HighlightMode("search") | redraw
    autocmd ColorScheme * call statusline#initialize()
    autocmd DiagnosticChanged * call statusline#HighlightDiagnostics()
    autocmd InsertEnter * call statusline#HighlightMode("insert")
    autocmd ModeChanged [^vV\x16]:[vV\x16]* call statusline#HighlightMode("visual")
    autocmd ModeChanged [^n]*:n* call statusline#HighlightMode("normal")
    autocmd TermEnter * call statusline#HighlightMode("terminal")
    autocmd TermEnter * call statusline#DefineTerminalStatusLine()
    autocmd TermLeave * call statusline#RedefineStatusLine()
    autocmd User CustomStatusline call statusline#RedefineStatusLine()
    autocmd VimEnter * autocmd Statusline
                \ BufWinEnter,BufWritePost,TextChanged,TextChangedI,WinEnter *
                \ call statusline#RedefineStatusLine()
    autocmd VimEnter * call timer_start(0, funcref("<SID>OnVimEnter"))
augroup END
if v:vim_did_enter
    doautocmd Statusline VimEnter
endif

call statusline#initialize()
