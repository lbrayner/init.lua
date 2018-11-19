function! statusline#extensions#netrw#cwdFlag()
    if ! exists("b:netrw_curdir")
        return ""
    endif
    if util#GetComparableNodeName(b:netrw_curdir) == util#GetComparableNodeName(getcwd())
        return "C"
    endif
    return ""
endfunction
