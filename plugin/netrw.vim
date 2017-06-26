" netrw is weird
augroup MVSL_FT_netrw
    autocmd!
    autocmd  FileType netrw
                \ let b:MVSL_custom_leftline = '%<%{fnamemodify(b:netrw_curdir, ":t")}%='
                \ . '%4*%{fnamemodify(b:netrw_curdir, ":~:h")}%*'
                \ . ' %3*%1.(%{MyVimStatusLine#extensions#netrw#cwdFlag()}%)%*'
    autocmd FileType netrw
                \ call MyVimStatusLine#statusline#DefineStatusLine()
augroup END
