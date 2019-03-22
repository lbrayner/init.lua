setlocal textwidth=80
setlocal tabstop=2
setlocal shiftwidth=2

function! s:Bolden(text)
    return '**'.a:text.'**'
endfunction

function! s:Italicize(text)
    return '*'.a:text.'*'
endfunction

nnoremap <buffer> <silent> gB ciW<c-r>=<SID>Bolden(getreg('"'))<cr><esc>B2l
nnoremap <buffer> <silent> gI ciW<c-r>=<SID>Italicize(getreg('"'))<cr><esc>Bl
