function s:Error(message)
    return "jasper.vim: " . a:message
endfunction

function! jasper#JasperVerticalDisplacement(displacement,...)
    if a:0 > 2
        echoerr s:Error("Three arguments at most.")
        return
    endif
    let minheight = 0
    if a:0 >= 1
        let minheight = a:1
    endif
    let maxheight = -1
    if a:0 >= 2
        let maxheight = a:2
    endif
    normal! v2atv
    exe "'<".','."'>"
                \ . 's/\(y="\)\@<=\(\d\+\)/\=(str2nr(submatch(2)) >= minheight'
                \ . ' && (maxheight < 0 || str2nr(submatch(2)) <= maxheight) ?'
                \ . ' str2nr(submatch(2))+a:displacement : submatch(2))/'
endfunction

function! jasper#JasperHorizontalDisplacement(displacement,...)
    if a:0 > 1
        echoerr s:Error("Two arguments at most.")
        return
    endif
    let minwidth = 0
    if a:0 > 0
        let minwidth = a:1
    endif
    %s/\(x="\)\@<=\(\d\+\)/\=(str2nr(submatch(2)) >= minwidth ?
                \ str2nr(submatch(2))+a:displacement : str2nr(submatch(2)))/
endfunction
