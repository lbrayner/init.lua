" netrw is weird
augroup MVSL_netrw
    autocmd! FileType
    au FileType netrw
        \ let &l:statusline = '%<%{fnamemodify(b:netrw_curdir, ":.")}%='
        \                   . MyVimStatusLine#statusline#GetStatusLineTail()
augroup END
