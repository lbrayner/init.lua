if exists("b:MVGoodies_did_ftplugin")
    finish
endif
let b:MVGoodies_did_ftplugin = 1

if &ft == 'java'

    " Command Declarations
    command! -buffer JavaBreakString
                \ :call append(line("."),java#format#break_string(getline("."))) | delete

    if executable('git')
        call MyVimGoodies#util#vimmap('nmap <buffer>'
                    \ ,'<leader>G','<Plug>MVGGitDiffThisExtDiff')
    endif
    if executable('svn')
        call MyVimGoodies#util#vimmap('nmap <buffer>'
            \ ,'<leader>D'
            \ ,'<Plug>MVGSVNDiffThisIgnoreAllWS')
    endif
    if MyVimGoodies#extensions#util#EclimLoaded()
        if MyVimGoodies#extensions#eclim#EclimAvailable()
            let projectName = eclim#project#util#GetCurrentProjectName()
            if projectName != ""
                let s:eclim = 1
                call MyVimGoodies#util#vimmap('nnoremap <buffer>',
                  \   '<leader>P',':let @"=eclim#java#util#GetPackage()<cr>'
                  \ . ':let @+=@" <cr> :let @*=@" <cr> :echo @"<cr>')
                call MyVimGoodies#util#vimmap('nnoremap <buffer> <silent>',
                  \   '<leader>C'
                  \ ,':call MyVimGoodies#extensions#eclim#EclimGoToClassDeclarationLine()<cr>')
                call MyVimGoodies#util#vimmap('nnoremap <buffer>'
                  \,'<leader>F'
                  \,':let @"=eclim#java#util#GetPackage().".".expand("%:t:r")<cr>'
                  \ . ':let @+=@" <cr> :let @*=@" <cr> :echo @"<cr>')
                call MyVimGoodies#util#vimmap
                            \('nnoremap <buffer>','<leader>js',':JavaSearch<space>')
                call MyVimGoodies#util#vimmap
                            \('nnoremap <buffer>','<leader>jr',':JavaRename<space>')
                call MyVimGoodies#util#vimmap
                            \('nnoremap <buffer>','<leader>ji',':JavaImport<cr>')
                call MyVimGoodies#util#vimmap
                            \('nnoremap <buffer>','<leader>jn',':JavaNew<space>')
                call MyVimGoodies#util#vimmap
                            \('nnoremap <buffer>','<leader>jg',':JavaGet')
                call MyVimGoodies#util#vimmap
                            \('nnoremap <buffer>','<leader>jc',':JavaConstructor<cr>')
                vnoremap <buffer> <leader>jc :JavaConstructor<cr>
                call MyVimGoodies#util#vimmap
                            \('nnoremap <buffer>','<leader>jo',':JavaImportOrganize<cr>')
                call MyVimGoodies#util#vimmap
                            \('nnoremap <buffer>','<leader>jm',':JavaMove<space>')
                if executable("ctags")
                    augroup CtagsJava
                        au!
                        autocmd  BufWritePost <buffer> call ctags#UpdateTags()
                    augroup END
                endif
                if v:vim_did_enter
                     call MyVimGoodies#extensions#eclim#EclimGoToClassDeclarationLine()
                endif
            endif
        endif
    endif
endif
