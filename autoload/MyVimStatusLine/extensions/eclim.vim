let s:specialFiletypeDic = {
            \ 'java': ''
            \ }

function! MyVimStatusLine#extensions#eclim#EclimLeftStatusLine()
    return expand('%:t:r')
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
    let loclist = 0
    let changed = 0
    let modifier = ''
    if exists("b:eclim_loclist")
        let loclist = len(getloclist(0))
    else
        let loclist = 0
    endif
    if exists("b:loclist_last")
        let loclist_last = b:loclist_last
    else
        let loclist_last = 0
    endif
    if loclist != loclist_last
        let changed = 1
        " echomsg "changed from ".loclist_last." to ".loclist
    endif
    if changed
        call MyVimStatusLine#extensions#eclim#LoadWarningFlag()
    else
        if loclist > 0
            let modifier = '?'
        else
            let b:warning_flag = ''
        endif
    endif
    return modifier.get(b:, 'warning_flag', '')
endfunction

function! MyVimStatusLine#extensions#eclim#LoadWarningFlag()
    let b:warning_flag = ''
    let errorlist = eclim#display#signs#GetExisting('error')
    if len(errorlist) > 0
        let b:warning_flag = 'E'
    endif
    if b:warning_flag == ''
        let warninglist = eclim#display#signs#GetExisting()
        if len(warninglist) > 0
            let b:warning_flag = 'W'
        endif
    endif
endfunction

function MyVimStatusLine#extensions#eclim#DefineEclimStatusLine()
    set statusline=%<%{MyVimStatusLine#extensions#eclim#ContextSensitiveLeftStatusLine()}%=
    set statusline+=\ %2*%{MyVimStatusLine#extensions#eclim#WarningFlag()}%*
    set statusline+=\ %4*%.20{MyVimStatusLine#extensions#eclim#CurrentProjectName()}%*
    set statusline+=\ %1*%{&ft}%*
    set statusline+=\ #%n
    set statusline+=\ %2*%1.(%{MyVimStatusLine#statusline#DefaultReadOnlyFlag()}%)%*
    set statusline+=%2*%1.(%{MyVimStatusLine#statusline#DefaultModifiedFlag()}%)%*
    set statusline+=\ %4.(%3*%{&fileformat}%*%)
    set statusline+=\ :%2.c\ %3*%L%*\ %3.P
    set statusline+=\ %3*%{&fileencoding}%*
endfunction
