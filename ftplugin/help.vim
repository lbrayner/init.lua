if &ft == 'help'
  augroup MyVimStatusLine_help
    autocmd! BufEnter <buffer>
    autocmd BufEnter <buffer> let b:MVSL_left_status_cmd = "expand('%:t')"
  augroup END
endif
