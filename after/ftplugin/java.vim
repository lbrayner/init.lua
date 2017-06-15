if &ft == 'java'
  augroup MyVimStatusLine_java
    autocmd! BufWritePre <buffer>
    autocmd BufWritePre <buffer> let b:loclist_last = len(getloclist(0))
                " \ | echomsg b:loclist_last
  augroup END
endif


