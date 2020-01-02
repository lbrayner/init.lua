function! jasper#JasperVerticalDisplacement(first,last,displacement,...)
    if a:0 > 4
        echoerr "jasper.vim: Five arguments at most."
        return
    endif
    let minheight = 0
    if a:0 >= 3
        let minheight = a:13
    endif
    let maxheight = -1
    if a:0 >= 4
        let maxheight = a:4
    endif
    call util#PreserveViewPort("keeppatterns ".a:first.','.a:last
                \ . 's/\(y="\)\@<=\(\d\+\)/\=(str2nr(submatch(2)) >= '.minheight
                \ . ' && ('.maxheight.' < 0 || str2nr(submatch(2)) <= '.maxheight.') ?'
                \ . ' str2nr(submatch(2))+'.a:displacement.' : submatch(2))/')
endfunction

function! jasper#JasperHorizontalDisplacement(first,last,displacement,...)
    if a:0 > 3
        echoerr s:Error("Four arguments at most.")
        return
    endif
    let minwidth = 0
    if a:0 >= 3
        let minwidth = a:3
    endif
    call util#PreserveViewPort('keeppatterns '.a:first.','.a:last
                \ .'s/\(x="\)\@<=\(\d\+\)/\=(str2nr(submatch(2)) >='
                \ .minwidth.' ? '
                \ .'str2nr(submatch(2))+'.a:displacement.' : str2nr(submatch(2)))/')
endfunction
