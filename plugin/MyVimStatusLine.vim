call MyVimStatusLine#statusline#DefineStatusLine()

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
    echoe "Unable to determine MyVimStatusLine's delay dir.  " .
    finish
endif

exec 'set runtimepath+='
    \ . delaydir . ','
    \ . delaydir . '/after'

augroup MyVimStatusLineInsertEnterLeave
    autocmd! InsertEnter * call MyVimStatusLine#HighlightMode('insert')
    autocmd! InsertLeave * call MyVimStatusLine#HighlightMode('normal')
augroup END

noremap <Plug>HighlightStatusLineNC  :call MyVimStatusLine#HighlightStatusLineNC()<CR>

if !exists(":HighlightStatusLineNC")
    command -nargs=0  HighlightStatusLineNC  :call s:HighlightStatusLineNC()
endif

call MyVimStatusLine#initialize()

call MyVimStatusLine#HighlightMode('normal')
call MyVimStatusLine#HighlightStatusLineNC()

