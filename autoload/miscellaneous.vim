" other

function! miscellaneous#SearchLastVisualSelectionNoMagic()
    normal! gvy
    let pattern = escape(@",'\/')
    exe "normal! /\\V" . pattern
    let @/="\\V" . pattern
endfunction
