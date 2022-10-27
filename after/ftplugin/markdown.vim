setlocal textwidth=80
setlocal tabstop=2
setlocal shiftwidth=2

if exists(":EasyAlign")
    " Align markdown table
    nnoremap <buffer> <silent> <Space>t vip:EasyAlign*\|<CR>
endif
