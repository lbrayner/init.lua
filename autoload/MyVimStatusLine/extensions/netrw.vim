function! MyVimStatusLine#extensions#netrw#cwdFlag()
    if ! exists("b:netrw_curdir")
        return ""
    endif
    if MyVimStatusLine#extensions#util#GetComparableFileName(b:netrw_curdir)
                \ == MyVimStatusLine#extensions#util#GetComparableFileName(getcwd())
        return "C"
    endif
    return ""
endfunction
