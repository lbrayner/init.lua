if ! has("gui_running")
    if &t_Co < 256
        finish
    endif
endif

" (not so) dexteriously copied from eclim's startup script

let delaydirrel = finddir('MyVimStatusLine.vim/delay/eclim', escape(&runtimepath, ' '))

let delaydir = substitute(fnamemodify(delaydirrel, ':p'), '\', '/', 'g')
let delaydir = substitute(delaydir, '.$', '','')

if delaydir == ''
    echoe "Unable to determine MyVimStatusLine's delay dir."
    finish
endif

exec 'set runtimepath+='
    \ . delaydir . ','
    \ . delaydir . '/after'

augroup MyVimStatusLineInsertEnterLeaveGroup
    autocmd!
    autocmd InsertEnter * call MyVimStatusLine#HighlightMode('insert')
    autocmd InsertLeave * call MyVimStatusLine#HighlightMode('normal')
augroup END

augroup MyVimStatusLineModifiedUserGroup
    autocmd!
    autocmd User * call MyVimStatusLine#RedefineStatusLine()
augroup END

augroup MyVimStatusLineModifiedBWEGroup
    autocmd!
    autocmd WinEnter * call MyVimStatusLine#RedefineStatusLine()
augroup END

augroup MyVimStatusLineWinLeaveGroup
    autocmd!
    autocmd WinLeave * call MyVimStatusLine#statusline#DefineStatusLineNoFocus()
augroup END

noremap <Plug>HighlightStatusLineNC  :call MyVimStatusLine#HighlightStatusLineNC()<CR>

if !exists(":HighlightStatusLineNC")
    command -nargs=0  HighlightStatusLineNC  :call s:HighlightStatusLineNC()
endif

call MyVimStatusLine#initialize()
