function! s:NavigateXmlNthParent(n)
    let n_command = "v" . (a:n+1) . "at"
    exec "silent normal! " . n_command . "vh"
endfunction

function! s:NavigateXmlDepth(depth)
    if a:depth < 0
        call s:NavigateXmlNthParent(-a:depth)
        return
    endif
endfunction

function! s:NavigateXmlDepthBackward(depth)
    call s:NavigateXmlDepth(a:depth)
    call matchit#Match_wrapper('',1,'n')
endfunction

nnoremap <silent> [< :call <SID>NavigateXmlDepthBackward(-v:count1)<cr>
nnoremap <silent> ]> :call <SID>NavigateXmlDepth(-v:count1)<cr>
