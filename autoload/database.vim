" vim-dadbod
function! s:SelectParagraph()
    exe "normal! vip:DB\<cr>"
endfunction

function! database#select_paragraph()
    call util#PreserveViewPort(funcref("<SID>SelectParagraph"))
endfunction
