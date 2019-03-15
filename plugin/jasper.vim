function s:Error(message)
    return "jasper.vim: " . a:message
endfunction

function! s:JasperVerticalDisplacement(displacement,...) range
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
    exe a:firstline.','.a:lastline
                \ . 's/\(y="\)\@<=\(\d\+\)/\=(submatch(2) >= minheight'
                \ . ' && (maxheight < 0 || submatch(2) <= maxheight) ?'
                \ . ' submatch(2)+a:displacement : submatch(2) )/g'
endfunction

function! s:JasperHorizontalDisplacement(displacement,...)
    if a:0 > 1
        echoerr s:Error("Two arguments at most.")
        return
    endif
    let minwidth = 0
    if a:0 > 0
        let minwidth = a:1
    endif
    %s/\(x="\)\@<=\(\d\+\)/\=(submatch(2) >= minwidth ?
                \ submatch(2)+a:displacement : submatch(2) )/g
endfunction

command! -range=% -nargs=+ JasperVerticalDisplacement
            \ <line1>,<line2>call <SID>JasperVerticalDisplacement(<f-args>)

command! -nargs=+ JasperHorizontalDisplacement
            \ call <SID>JasperHorizontalDisplacement(<f-args>)
