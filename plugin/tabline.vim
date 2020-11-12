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
    let isabsolute=len(expand("%")) <= 0 ? 0
                \: stridx(expand("%:p"),fnamemodify(getcwd(),":p:gs?\\?/?")) != 0
    if isabsolute
        " At least one column separating left and right and a 1 column margin
        let absolute_path=util#truncateFilename(fnamemodify(expand("%"),
                    \":p:~"),float2nr(0.5*&columns)-2)
        let &tabline='%#Title#%4.{tabpagenr()}%#Normal# '
            \ .'%#NonText#'.cwd.'%=%#WarningMsg# '.absolute_path.' '
        return
    endif
    " At least one column separating left and right and a 1 column margin
    let relative_dir=util#truncateFilename(substitute(
                \fnamemodify(expand("%:h"),":~"),'\V'.cwd.'/\?',"",""),
                \float2nr(0.5*&columns)-2)
    " For some reason, sometimes '%' expands to the full path even if it's in
    " the cwd (don't know if it's a neovim or vim thing)
    if relative_dir == ""
        let relative_dir="."
    endif
    let &tabline='%#Title#%4.{tabpagenr()}%#Normal# '
        \ .'%#NonText#'.substitute(cwd,'/$',"","").'%=%#Directory# '.relative_dir.' '
endfunction

augroup Tabline
    autocmd!
    autocmd VimEnter * autocmd Tabline
                \ BufWritePost,BufEnter,WinEnter,DirChanged * call RedefineTabline()
    autocmd VimEnter * call RedefineTabline()
augroup END
