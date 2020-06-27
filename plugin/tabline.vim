if !has("windows")
    finish
endif

set showtabline=2

function! RedefineTabline()
    " To be displayed on the left side
    let cwd=fnamemodify(getcwd(),":~")
    " Is it outside of cwd? Recent versions of getcwd() return paths with backward
    " slashes on win32
    " Similar to Java's String.startsWith
    let isabsolute=stridx(expand("%:p"),fnamemodify(getcwd(),":p:gs?\\?/?")) != 0
    if isabsolute
        " At least one column separating left and right and a 1 column margin
        let absolute_path=util#truncateFilename(fnamemodify(expand("%"),
                    \":p:~"),float2nr(0.5*&columns)-2)
        let &tabline='%#Title#%4.{tabpagenr()}%#Normal# '
            \ .'%#NonText#'.cwd.'%=%#WarningMsg# '.absolute_path.' '
        return
    endif
    " At least one column separating left and right and a 1 column margin
    let relative_dir=util#truncateFilename(expand("%:h"),float2nr(0.5*&columns)-2)
    let &tabline='%#Title#%4.{tabpagenr()}%#Normal# '
        \ .'%#NonText#'.cwd.'%=%#Directory# '.relative_dir.' '
endfunction

augroup Tabline
    autocmd!
    autocmd VimEnter * autocmd Tabline
                \ BufWritePost,BufEnter,WinEnter * call RedefineTabline()
    autocmd VimEnter * call RedefineTabline()
augroup END
