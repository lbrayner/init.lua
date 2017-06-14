function! DefaultLeftStatusLine()
    return expand('%')
endfunction

function! s:EclimLeftStatusLine()
    return expand('%:t')
endfunction

function! ContextSensitiveStatusLine()
    let projectName = eclim#project#util#GetCurrentProjectName()
    if projectName == ""
        return DefaultLeftStatusLine()
    endif
    return s:EclimLeftStatusLine()
endfunction

function s:DefineContextSensitiveStatusLine()
    " set statusline=%<%{ContextSensitiveStatusLine()}%=\ %1*%y%*
    set statusline=%<%{ContextSensitiveStatusLine()}%=
    set statusline+=\ %2*%.13{eclim#project#util#GetCurrentProjectName()}%*\ %1*%y%*
endfunction

function s:DefineDefaultLeftStatusLine()
    set statusline=%<%{DefaultLeftStatusLine()}%=\ %1*%y%*
endfunction

set statusline+=\ %4.(#%n%)

try
    call eclim#project#util#GetCurrentProjectName()
    call s:DefineContextSensitiveStatusLine()
catch /E117/ 
    call s:DefineDefaultLeftStatusLine()
endtry

set statusline+=\ %4.(#%n%)
set statusline+=\ %2*%2.(%R%)\ %1.(%M%)%*
set statusline+=\ %4.(%3*%{&fileformat}%*%)
set statusline+=\ %4.l:%4.(%c%V%)\ %4*%L%*\ %3.P
set statusline+=\ %5*%{&fileencoding}%*

call MyVimStatusLine#initialize()

call MyVimStatusLine#HighlightMode('normal')
call MyVimStatusLine#HighlightStatusLineNC()
