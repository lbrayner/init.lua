" Only do this when not done yet for this buffer
if exists("b:MVSL_did_ftplugin")
    finish
endif
let b:did_ftplugin = 1

if &ft == 'java'
  if MyVimStatusLine#extensions#util#EclimLoaded()
      if MyVimStatusLine#extensions#eclim#EclimAvailable()
          let projectName = eclim#project#util#GetCurrentProjectName()
          if projectName != ""
              augroup MVSL_java
                    autocmd!
                    autocmd! BufWritePost <buffer> call MyVimStatusLine#extensions#eclim#LoadWarningFlag()
                    autocmd! BufEnter <buffer>
                        \ let &l:statusline = '%<%{expand("%:t:r")}%='
                        \                   . ' %2*%{MyVimStatusLine#extensions#eclim#WarningFlag()}'
                        \             . ' %4*%.20{MyVimStatusLine#extensions#eclim#CurrentProjectName()}%*'
                        \                   . MyVimStatusLine#statusline#GetStatusLineTail()
              augroup END
          endif
      endif
  endif
endif
