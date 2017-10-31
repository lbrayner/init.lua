" Only do this when not done yet for this buffer
if exists("b:MVGoodies_did_ftplugin")
    finish
endif
let b:MVGoodies_did_ftplugin = 1

if &ft == 'java'
    if MyVimGoodies#extensions#util#EclimLoaded()
      if MyVimGoodies#extensions#eclim#EclimAvailable()
          let projectName = eclim#project#util#GetCurrentProjectName()
          if projectName != ""
              augroup MVGoodies_BE_java
                    autocmd! BufEnter <buffer>
                    autocmd  BufEnter <buffer>
                        \ call MyVimGoodies#util#vimmap('nnoremap <buffer>',
                        \   '<leader>P',':let @"=eclim#java#util#GetPackage()<cr>'
    \ . ':let @+=@" <cr> :let @*=@" <cr> :echo @"<cr>')
                    autocmd  BufEnter <buffer>
                        \   call MyVimGoodies#util#vimmap('nnoremap <buffer> <silent>',
                        \   '<leader>T'
            \ ,':call MyVimGoodies#extensions#eclim#EclimGoToClassDeclarationLine()<cr>')
                    autocmd  BufEnter <buffer>
                        \ call MyVimGoodies#util#vimmap('nnoremap <buffer>',
    \   '<leader>F',':let @"=eclim#java#util#GetPackage().".".expand("%:t:r")<cr>'
    \ . ':let @+=@" <cr> :let @*=@" <cr> :echo @"<cr>')
                    autocmd  BufEnter <buffer>
                        \ call MyVimGoodies#util#vimmap('nnoremap <buffer>',
                        \   '<leader>S',':JavaSearch<space>')
              augroup END
              if v:vim_did_enter
                   call MyVimGoodies#extensions#eclim#EclimGoToClassDeclarationLine()
              endif
          endif
      endif
    endif
    if executable('git')
        call MyVimGoodies#util#vimmap('nmap <buffer>'
                    \ ,'<leader>G','<Plug>MVGGitDiffThisExtDiff')
    endif
    if executable('svn')
        call MyVimGoodies#util#vimmap('nmap <buffer>'
            \ ,'<leader>D'
            \ ,'<Plug>MVGSVNDiffThisIgnoreAllWS')
    endif
endif
