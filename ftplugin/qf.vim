setlocal nospell
setlocal nowrap

if util#isLocationList()
    nnoremap <buffer> <silent> <F3> <c-w>p:lprevious<cr>zz:lopen<cr>
    nnoremap <buffer> <silent> <F4> <c-w>p:lnext<cr>zz:lopen<cr>
else
    nnoremap <buffer> <silent> <F3> <c-w>p:cprevious<cr>zz:copen<cr>
    nnoremap <buffer> <silent> <F4> <c-w>p:cnext<cr>zz:copen<cr>
endif
