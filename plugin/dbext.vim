function! DBextPostResult(...)
    " removing an undesirable mapping
    unmap <buffer> q
    if b:dbext_type ==# "MYSQL"
        if b:dbext_extra =~# "vvv"
            syn region ResultFold start="^--------------$" end="^--------------$" keepend transparent fold
            syn sync fromstart
            setlocal foldmethod=syntax
        endif
    endif
endfunction
