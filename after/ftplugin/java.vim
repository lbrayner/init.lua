if &ft == 'java'
  if MyVimStatusLine#extensions#eclim#EclimLoaded()
      augroup MyVimStatusLine_java
            autocmd! BufEnter <buffer>
            autocmd BufEnter <buffer> let b:MVSL_left_status_cmd = "expand('%:t:r')"
      augroup END
  endif
endif
