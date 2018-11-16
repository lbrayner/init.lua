function! StatuslineNetrwCurdirHead()
    " left: a space + 2 extra spaces = 3
    " right: ft (netrw), RO Flag, 3 spaces, P(ercentage) = 12
    let maxlength = winwidth("%") - len(fnamemodify(b:netrw_curdir,":t")) - 3 - 12
    return util#truncateDirname(fnamemodify(b:netrw_curdir,":~:h"),maxlength)
endfunction

" netrw is weird
augroup Statusline_FT_netrw
    autocmd!
    autocmd  FileType netrw
                \ let b:Statusline_custom_leftline = 
                \   '%<%{fnamemodify(b:netrw_curdir, ":t")}%='
    autocmd  FileType netrw
                \ let b:Statusline_custom_rightline =
                \   '%4*%{StatuslineNetrwCurdirHead()}%*'
                \ . ' %3*%1.(%{statusline#extensions#netrw#cwdFlag()}%)%*'
                \ . ' %2*%{&ft}%*'
                \ . ' %3*%1.(%{statusline#DefaultReadOnlyFlag()}%)%*'
                \ . ' %3.P'
    autocmd FileType netrw
                \ call statusline#DefineStatusLine()
augroup END
