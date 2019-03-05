if !has("windows")
    finish
endif

set showtabline=2

function! RedefineTabline()
    let &tabline='%#Title#%4.{tabpagenr()}%#Normal# '
        \ . '%#NonText#%{fnamemodify(getcwd(),":~")}%=%#Directory# '
        \ . '%{util#truncateFilename(expand("%"),float2nr(0.5*&columns))} '
    " Is an absolute path? Recent versions of getcwd() return paths with backward
    " slashes on win32
    let isabsolute=expand("%:p") !~# fnamemodify(getcwd(),":p:gs?\\?/?")
    if isabsolute
        let &tabline='%#Title#%4.{tabpagenr()}%#Normal# '
            \ . '%#NonText#%{fnamemodify(getcwd(),":~")}%=%#WarningMsg#'
            \ . ' %{util#truncateFilename('
                \ . 'fnamemodify(expand("%"),":p:~"),float2nr(0.5*&columns))} '
    endif
endfunction

augroup TablineBufWinEnter
    autocmd!
    autocmd WinEnter,BufEnter * call RedefineTabline()
augroup END
