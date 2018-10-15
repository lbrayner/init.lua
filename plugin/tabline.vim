if !has("windows")
    finish
endif

set showtabline=2

function! RedefineTabline()
    let &tabline='%#Title#%4.{tabpagenr()}%#Normal# '
        \ . '%#NonText#%{fnamemodify(getcwd(),":~")}%=%#Directory# %{expand("%:h")} '
    " Is an absolute path? Recent versions of getcwd() return paths with backward
    " slashes on win32
    let isabsolute=expand("%:p") !~# fnamemodify(getcwd(),":p:gs?\\?/?")
    if isabsolute
        let &tabline='%#Title#%4.{tabpagenr()}%#Normal# '
            \ . '%#NonText#%{fnamemodify(getcwd(),":~")}%=%#WarningMsg#'
            \. ' %{fnamemodify(expand("%"),":p:~")} '
    endif
endfunction

augroup TablineBufWinEnter
    autocmd!
    autocmd WinEnter,BufEnter * call RedefineTabline()
augroup END
