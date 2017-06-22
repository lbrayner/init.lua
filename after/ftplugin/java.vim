" Only do this when not done yet for this buffer
if exists("b:MVGoodies_did_ftplugin")
    finish
endif
let b:did_ftplugin = 1

if &ft == 'java'
    if MyVimGoodies#extensions#util#EclimLoaded()
      if MyVimGoodies#extensions#eclim#EclimAvailable()
          let projectName = eclim#project#util#GetCurrentProjectName()
          if projectName != ""
              augroup MVGoodies_BE_java
                    autocmd! BufEnter <buffer>
                    autocmd  BufEnter <buffer>
                        \ call MyVimGoodies#util#vimmap('nnoremap <buffer>',
                        \   '<leader>P',':echo eclim#java#util#GetPackage()<cr>')
                    autocmd  BufEnter <buffer>
                        \ call MyVimGoodies#util#vimmap('nnoremap <buffer>',
                        \   '<leader>T'
    \ ,':silent call MyVimGoodies#extensions#eclim#EclimGoToClassDeclarationLine()<cr>')
                    autocmd  BufEnter <buffer>
                        \ silent call 
                        \   MyVimGoodies#extensions#eclim#EclimGoToClassDeclarationLine()
              augroup END
          endif
      endif
    endif
endif
