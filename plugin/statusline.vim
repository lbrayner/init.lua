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
    set updatetime=4000
    call statusline#HighlightMode('normal')
endfunction

vnoremap <silent> <expr> <SID>VisualModeEnter VisualModeEnter()
nnoremap <silent> <script> v v<SID>VisualModeEnter
nnoremap <silent> <script> gv gv<SID>VisualModeEnter
nnoremap <silent> <script> V V<SID>VisualModeEnter
nnoremap <silent> <script> <C-v> <C-v><SID>VisualModeEnter

function! CmdlineModeLeave()
    if exists("s:lazyredraw")
        let &lazyredraw = s:lazyredraw
    endif
    call statusline#HighlightPreviousMode()
    autocmd! CmdlineModeHighlight CmdlineLeave
endfunction

function! CmdlineModeEnter()
    call statusline#HighlightMode('command')
    augroup CmdlineModeHighlight
        autocmd CmdlineLeave * call CmdlineModeLeave()
    augroup END
    let s:lazyredraw = &lazyredraw
    set nolazyredraw
endfunction

nnoremap <silent> <Plug>(Cmd) :call CmdlineModeEnter()<cr>:
vnoremap <silent> <Plug>(Cmd) :<c-u>call CmdlineModeEnter() <bar> normal! gv<cr>:

" Autocommands

augroup Statusline
    autocmd!
    autocmd InsertEnter * call statusline#HighlightMode('insert')
    autocmd InsertLeave * call statusline#HighlightMode('normal')
    autocmd CmdlineEnter /,\? call statusline#HighlightMode('search') | redrawstatus
    autocmd CmdlineLeave /,\? call statusline#HighlightPreviousMode()
    autocmd CursorHold * call VisualModeLeave()
    autocmd User CustomStatusline call statusline#RedefineStatusLine()
    autocmd VimEnter * autocmd Statusline
                \ BufWritePost,BufWinEnter,WinEnter * call statusline#RedefineStatusLine()
    autocmd VimEnter * autocmd Statusline
                \ BufLeave * call statusline#DefineStatusLineNoFocus()
    autocmd VimEnter * call statusline#initialize()
    autocmd VimEnter * call statusline#RedefineStatusLine()
    autocmd ColorScheme * call statusline#initialize()
augroup END

" vim: fdm=marker
