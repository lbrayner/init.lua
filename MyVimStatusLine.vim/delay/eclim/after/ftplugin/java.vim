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
              augroup MVSL_BWP_java
                    autocmd! BufWritePost <buffer>
                    autocmd  BufWritePost <buffer> 
                                \ call MyVimStatusLine#extensions#eclim#LoadWarningFlag()
              augroup END
              let b:MVSL_custom_leftline = '%<%{expand("%:t:r")}'
              \ . '%{MyVimStatusLine#statusline#DefaultModifiedFlag()}%='
              \ . ' %5*%.20{MyVimStatusLine#extensions#eclim#CurrentProjectName()}%*'
              \ . ' %3*%{MyVimStatusLine#extensions#eclim#WarningFlag()}'
              let b:MVSL_custom_mod_leftline = '%<%1*%{expand("%:t:r")}'
              \ . '%{MyVimStatusLine#statusline#DefaultModifiedFlag()}%*%='
              \ . ' %5*%.20{MyVimStatusLine#extensions#eclim#CurrentProjectName()}%*'
              \ . ' %3*%{MyVimStatusLine#extensions#eclim#WarningFlag()}'
              call MyVimStatusLine#statusline#DefineStatusLine()
          endif
      endif
  endif
endif
