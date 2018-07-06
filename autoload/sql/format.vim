let g:sql#format#length = 80

function! sql#format#break_string(code)
    return format#break_string("'","'","||",g:sql#format#length,a:code)
endfunction
