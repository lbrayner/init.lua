" netrw is weird
augroup MVSL_netrw
    autocmd!
    au FileType netrw let b:MVSL_left_status_cmd = "fnamemodify(b:netrw_curdir, ':.')"
augroup END
