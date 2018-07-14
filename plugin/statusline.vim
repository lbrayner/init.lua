if ! has("gui_running")
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

augroup StatuslineInsertEnterLeaveGroup
    autocmd!
    autocmd InsertEnter * call statusline#HighlightMode('insert')
    autocmd InsertLeave * call statusline#HighlightMode('normal')
augroup END

augroup StatuslineModifiedUserGroup
    autocmd!
    autocmd User * call statusline#RedefineStatusLine()
augroup END

augroup StatuslineModifiedBWEGroup
    autocmd!
    autocmd BufWinEnter,WinEnter * call statusline#RedefineStatusLine()
augroup END

augroup StatuslineWinLeaveGroup
    autocmd!
    autocmd BufLeave * call statusline#DefineStatusLineNoFocus()
augroup END

noremap <Plug>HighlightStatusLineNC  :call statusline#HighlightStatusLineNC()<CR>

if !exists(":HighlightStatusLineNC")
    command -nargs=0  HighlightStatusLineNC  :call s:HighlightStatusLineNC()
endif

command! -nargs=0 StatusLineInitialize call statusline#initialize()
