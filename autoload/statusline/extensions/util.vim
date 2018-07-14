function! statusline#extensions#util#EclimLoaded()
    return exists(':ProjectCreate')
endfunction

function! statusline#extensions#util#GetComparableFileName(filename)
    return substitute(fnamemodify(a:filename,":p"),'\','/','g')
endfunction
