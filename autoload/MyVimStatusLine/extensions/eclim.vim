let s:specialFiletypeDic = {
            \ 'java': ''
            \ }

function! MyVimStatusLine#extensions#eclim#EclimLeftStatusLine()
    return expand('%:t')
endfunction

function! MyVimStatusLine#extensions#eclim#EclimAvailable()
    return eclim#EclimAvailable(0)
endfunction

function! MyVimStatusLine#extensions#eclim#CurrentProjectName()
    let eclimAvailable = MyVimStatusLine#extensions#eclim#EclimAvailable()
    if eclimAvailable
        return eclim#project#util#GetCurrentProjectName()
    endif
    return ""
endfunction

function! MyVimStatusLine#extensions#eclim#ContextSensitiveLeftStatusLine()
    let projectName = MyVimStatusLine#extensions#eclim#CurrentProjectName()
    if projectName == ""
        return MyVimStatusLine#statusline#DefaultLeftStatusLine()
    endif
    let filetype = &ft
    if !has_key(s:specialFiletypeDic,filetype)
        return MyVimStatusLine#statusline#DefaultLeftStatusLine()
    endif
    return MyVimStatusLine#extensions#eclim#EclimLeftStatusLine()
endfunction

function! MyVimStatusLine#extensions#eclim#WarningFlag()
    let errorlist = eclim#display#signs#GetExisting('error')
    if len(errorlist) > 0
        return 'E'
    endif
    let warninglist = eclim#display#signs#GetExisting()
    if len(warninglist) > 0
        return 'W'
    endif
    return ''
endfunction

function MyVimStatusLine#extensions#eclim#DefineEclimStatusLine()
    set statusline=%<%{MyVimStatusLine#extensions#eclim#ContextSensitiveLeftStatusLine()}%=
    set statusline+=\ %4*%.20{MyVimStatusLine#extensions#eclim#CurrentProjectName()}%*\ %1*%{&ft}%*
    set statusline+=\ %2*%1.(%{MyVimStatusLine#extensions#eclim#WarningFlag()}%)%*\ %4.(#%n%)
    set statusline+=\ %2*%2.(%R%)\ %1.(%M%)%*
    set statusline+=\ %4.(%3*%{&fileformat}%*%)
    set statusline+=\ %3.l:%2.c\ %3*%L%*\ %3.P
    set statusline+=\ %3*%{&fileencoding}%*
endfunction
