function! statusline#extensions#util#GetComparableFileName(filename)
    return substitute(fnamemodify(a:filename,":p"),'\','/','g')
endfunction
