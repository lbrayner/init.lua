if &ft == 'help'
  augroup MVSL_help
    autocmd! BufEnter <buffer>
    autocmd! BufEnter <buffer>
        \ let &l:statusline = '%<%{expand("%:t")}%='
        \                   . MyVimStatusLine#statusline#GetStatusLineTail()
  augroup END
endif
