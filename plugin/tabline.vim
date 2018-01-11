if !has("windows")
    finish
endif

set showtabline=2

function! RedefineTabline()
    let &tabline='%#Title#%4.{tabpagenr()}%#Normal# '
        \ . '%#Question#%{fnamemodify(getcwd(),":~")}%=%#TabLineSel# %{expand("%:h")} '
    let isabsolute=expand("%:p") !~# getcwd() " is an absolute path
    if isabsolute
        let &tabline='%#Title#%4.{tabpagenr()}%#Normal# '
            \ . '%#Question#%{fnamemodify(getcwd(),":~")}%=%#ErrorMsg#'
            \. ' %{fnamemodify(expand("%"),":p:~")} '
    endif
endfunction

augroup TablineBufWinEnter
    autocmd!
    autocmd WinEnter * call RedefineTabline()
augroup END
