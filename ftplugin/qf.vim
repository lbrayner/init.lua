if &ft == 'qf'
    let b:Statusline_custom_leftline = '%<'
            \ . '%f'
            \ . '%{statusline#DefaultModifiedFlag()}%='
    setlocal nospell
endif

if util#isLocationList()
    nnoremap <buffer> <silent> <F3> :lprevious<cr>zz<c-w>ww
    nnoremap <buffer> <silent> <F4> :lnext<cr>zz<c-w>ww
else
    nnoremap <buffer> <silent> <F3> :cprevious<cr>zz<c-w>ww
    nnoremap <buffer> <silent> <F4> :cnext<cr>zz<c-w>ww
endif
