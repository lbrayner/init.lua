function! statusline#extensions#dbext#dbext_var(dbext_var)
    if exists(a:dbext_var)
        exec "let value = ".a:dbext_var
        if value != ""
            return ":".value
        endif
    endif
    return ""
endfunction
