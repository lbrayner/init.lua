if !has("gui_running")
    if &t_Co < 256
        finish
    endif
endif

" (not so) dexteriously copied from eclim's startup script

let delaydirrel = finddir('statusline/delay/eclim', escape(&runtimepath, ' '))

let delaydir = substitute(fnamemodify(delaydirrel, ':p'), '\', '/', 'g')
let delaydir = substitute(delaydir, '.$', '','')

if delaydir == ''
    echoe "Unable to determine statusline's delay dir."
    finish
endif

exec 'set runtimepath+='
    \ . delaydir . ','
    \ . delaydir . '/after'

command! -nargs=0 StatusLineInitialize call statusline#initialize()

" Visual Mode

" References {{{
" https://stackoverflow.com/questions/16165350/how-to-emulate-autocmd-visualleave-or-autocmd-visualenter-in-vim
" }}}

function! VisualModeEnter()
    set updatetime=1
    call statusline#HighlightMode('visual')
    return util#trivialHorizontalMotion()
endfunction

function! VisualModeLeave()
    call statusline#HighlightMode('normal')
endfunction

vnoremap <silent> <expr> <SID>VisualModeEnter VisualModeEnter()
nnoremap <silent> <script> v v<SID>VisualModeEnter
nnoremap <silent> <script> gv gv<SID>VisualModeEnter
nnoremap <silent> <script> V V<SID>VisualModeEnter
nnoremap <silent> <script> <C-v> <C-v><SID>VisualModeEnter

function! CmdlineModeLeave()
    autocmd! CmdlineModeHighlight CmdlineLeave
    if g:statusline#previousMode != 'visual'
        call statusline#HighlightPreviousMode()
    endif
endfunction

function! CmdlineModeEnter()
    call statusline#HighlightMode('command')
    augroup CmdlineModeHighlight
        autocmd CmdlineLeave * call CmdlineModeLeave()
    augroup END
endfunction

noremap <Plug>(Cmd) <Cmd>call CmdlineModeEnter() <bar> redrawstatus<CR>:

" Autocommands

" Setting a default not current statusline
" margins of 1 column (on both sides)
let &statusline=" %f "

augroup Statusline
    autocmd!
    autocmd InsertEnter * call statusline#HighlightMode('insert')
    autocmd InsertLeave * call statusline#HighlightMode('normal')
    " TODO redrawstatus should work here, create an issue on github
    autocmd CmdlineEnter /,\? call statusline#HighlightMode('search') | redraw
    autocmd CmdlineLeave /,\? call statusline#HighlightPreviousMode()
    if has("nvim")
        autocmd TermEnter * call statusline#HighlightMode('terminal')
        autocmd TermEnter * call statusline#DefineTerminalStatusLine()
        autocmd TermLeave * call statusline#HighlightMode('normal')
        autocmd TermLeave * call statusline#RedefineStatusLine()
        autocmd TermLeave * set fillchars<
    elseif !has("win32unix")
        " Vim 8.2
        autocmd TerminalWinOpen * call statusline#DefineTerminalStatusLine()
    endif
    autocmd CmdwinEnter,CmdwinLeave * call statusline#HighlightMode('normal')
    autocmd CursorHold * call VisualModeLeave()
    autocmd User CustomStatusline call statusline#RedefineStatusLine()
    autocmd VimEnter * autocmd Statusline
                \ BufWritePost,BufWinEnter,WinEnter * call statusline#RedefineStatusLine()
    autocmd VimEnter * autocmd Statusline
                \ WinLeave * call statusline#DefineStatusLineNoFocus()
    autocmd VimEnter * call statusline#initialize()
    autocmd VimEnter * call statusline#RedefineStatusLine()
    autocmd ColorScheme * call statusline#initialize()
    if has("nvim")
        autocmd DiagnosticChanged * call statusline#RedefineStatusLine()
    endif
augroup END
if v:vim_did_enter
    doautocmd Statusline VimEnter
endif

" vim: fdm=marker
