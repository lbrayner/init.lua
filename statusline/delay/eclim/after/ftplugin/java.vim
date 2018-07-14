if exists("b:Statusline_did_ftplugin")
    finish
endif
let b:Statusline_did_ftplugin = 1

if &ft == 'java'
  if statusline#extensions#util#EclimLoaded()
      if statusline#extensions#eclim#EclimAvailable()
          let projectName = eclim#project#util#GetCurrentProjectName()
          if projectName != ""
              augroup Statusline_BWP_java
                    autocmd! BufWritePost <buffer>
                    autocmd  BufWritePost <buffer> 
                                \ call statusline#extensions#eclim#LoadWarningFlag()
              augroup END
              let b:Statusline_custom_leftline = '%<%{expand("%:t:r")}'
              \ . '%{statusline#statusline#DefaultModifiedFlag()}%='
              \ . ' %5*%.20{statusline#extensions#eclim#CurrentProjectName()}%*'
              \ . ' %3*%{statusline#extensions#eclim#WarningFlag()}'
              let b:Statusline_custom_mod_leftline = '%<%1*%{expand("%:t:r")}'
              \ . '%{statusline#statusline#DefaultModifiedFlag()}%*%='
              \ . ' %5*%.20{statusline#extensions#eclim#CurrentProjectName()}%*'
              \ . ' %3*%{statusline#extensions#eclim#WarningFlag()}'
              call statusline#statusline#DefineStatusLine()
              " setting &l:path
              let &l:path=projectName.",".&path
          endif
      endif
  endif
endif
