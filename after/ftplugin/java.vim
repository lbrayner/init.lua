if &ft == 'java'
  if MyVimStatusLine#extensions#util#EclimLoaded()
      if MyVimStatusLine#extensions#eclim#EclimAvailable()
          let projectName = eclim#project#util#GetCurrentProjectName()
          if projectName != ""
              augroup MVSL_java
                    autocmd! BufEnter <buffer>
                        \ let &l:statusline = '%<%{expand("%:t:r")}%='
                        \                   . ' %2*%{MyVimStatusLine#extensions#eclim#WarningFlag()}'
                        \             . ' %4*%.20{MyVimStatusLine#extensions#eclim#CurrentProjectName()}%*'
                        \                   . MyVimStatusLine#statusline#status_line_tail
              augroup END
          endif
      endif
  endif
endif
