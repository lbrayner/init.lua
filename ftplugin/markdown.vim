setlocal textwidth=80
setlocal tabstop=2
setlocal shiftwidth=2

" TODO Redo functionality. See tpope's vim-surround
function! s:Bolden(text)
    return '**'.a:text.'**'
endfunction

function! s:Italicize(text)
    return '*'.a:text.'*'
endfunction

nnoremap <buffer> <silent> gB ciw<c-r>=<SID>Bolden(getreg('"'))<cr><esc>B2l
nnoremap <buffer> <silent> gI ciw<c-r>=<SID>Italicize(getreg('"'))<cr><esc>Bl
