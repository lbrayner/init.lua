function! statusline#extensions#netrw#cwdFlag()
    if ! exists("b:netrw_curdir")
        return ""
    endif
    if statusline#extensions#util#GetComparableFileName(b:netrw_curdir)
                \ == statusline#extensions#util#GetComparableFileName(getcwd())
        return "C"
    endif
    return ""
endfunction
