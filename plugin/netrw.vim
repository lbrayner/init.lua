" netrw is weird
augroup MVSL_FT_netrw
    autocmd! FileType
    autocmd! BufEnter <buffer>
    au FileType netrw
        \ let &l:statusline = '%<%{fnamemodify(b:netrw_curdir, ":t")}%='
        \                   . '%5*%{fnamemodify(b:netrw_curdir, ":~:h")}%*'
        \                   . MyVimStatusLine#statusline#GetStatusLineTail()
augroup END
