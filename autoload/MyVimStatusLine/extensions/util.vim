function! MyVimStatusLine#extensions#util#EclimLoaded()
    return exists(':ProjectCreate')
endfunction

function! MyVimStatusLine#extensions#util#GetComparableFileName(filename)
    return substitute(fnamemodify(a:filename,":p"),'\','/','g')
endfunction
