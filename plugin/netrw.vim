" netrw is weird
augroup MVSL_FT_netrw
    autocmd! FileType
    autocmd! BufEnter <buffer>
    au FileType netrw
        \ let &l:statusline = '%<%{fnamemodify(b:netrw_curdir, ":t")}%='
        \                   . '%3*%{fnamemodify(b:netrw_curdir, ":~:h")}%*'
        \                   . ' %2*%1.(%{MyVimStatusLine#extensions#netrw#cwdFlag()}%)%*'
        \                   . MyVimStatusLine#statusline#GetStatusLineTail()
augroup END
