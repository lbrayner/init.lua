function! s:NavigateNthParent(n)
    exec "silent normal! v".(a:n+1)."ath"
    exec "silent normal! \<Esc>"
endfunction

function! xml#NavigateDepth(depth)
    if a:depth < 0
        call xml#NavigateDepthBackward(-a:depth)
        return
    endif
    call s:NavigateNthParent(a:depth)
endfunction

function! xml#NavigateDepthBackward(depth)
    if a:depth < 0
        call xml#NavigateDepth(-a:depth)
        return
    endif
    call xml#NavigateDepth(a:depth)
    call matchit#Match_wrapper('',1,'n')
endfunction
