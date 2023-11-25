" vim: sw=4
" a string or a 0-arg funcref
function! util#PreserveViewPort(command)
    let lazyr = &lazyredraw
    try
        set lazyredraw
        let winview = winsaveview()
        if type(a:command) == type(function("tr"))
            call a:command()
        else
            exe a:command
        endif
        call winrestview(winview)
    finally
        let &lazyredraw = lazyr
    endtry
endfunction

function! util#Options(...)
    if a:0 == 1
        if exists(a:1)
            exec "let value = ".a:1
            if value != ""
                return value
            endif
        endif
        return a:1
    endif
    if a:0 > 1
        for index in range(0,a:0-2)
            if exists(a:000[index])
                exec "let value = ".a:000[index]
                if value != ""
                    return value
                endif
            endif
        endfor
        " Default value (can be a constant, i.e. string or number)
        if exists(a:000[a:0-1])
            exec "let value = ".a:000[a:0-1]
            if value != ""
                return value
            endif
        endif
        return a:000[a:0-1]
    endif
endfunction
