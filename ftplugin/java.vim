if exists("b:my_did_ftplugin")
    finish
endif
let b:my_did_ftplugin = 1

if &ft == 'java'

    " Command Declarations
    command! -buffer JavaBreakString
                \ :call append(line("."),java#format#break_string(getline("."))) | delete
    command! -buffer -range JavaStringify
                \ <line1>,<line2>call java#format#stringify()

    if executable('git')
        call util#vimmap('nmap <buffer>'
                    \ ,'<leader>G','<Plug>MVGGitDiffThisExtDiff')
    endif
    if executable('svn')
        call util#vimmap('nmap <buffer>'
            \ ,'<leader>D'
            \ ,'<Plug>MVGSVNDiffThisIgnoreAllWS')
    endif
    if extensions#util#EclimLoaded()
        if extensions#eclim#EclimAvailable()
            let projectName = eclim#project#util#GetCurrentProjectName()
            if projectName != ""
                let s:eclim = 1
                call util#vimmap('nnoremap <buffer>',
                  \   '<leader>P',':let @"=eclim#java#util#GetPackage()<cr>'
                  \ . ':let @+=@" <cr> :let @*=@" <cr> :echo @"<cr>')
                call util#vimmap('nnoremap <buffer> <silent>',
                  \   '<leader>C'
                  \ ,':call extensions#eclim#EclimGoToClassDeclarationLine()<cr>')
                call util#vimmap('nnoremap <buffer>'
                  \,'<leader>F'
                  \,':let @"=eclim#java#util#GetPackage().".".expand("%:t:r")<cr>'
                  \ . ':let @+=@" <cr> :let @*=@" <cr> :echo @"<cr>')
                call util#vimmap
                            \('nnoremap <buffer>','<leader>js',':JavaSearch<space>')
                call util#vimmap
                            \('nnoremap <buffer>','<leader>jr',':JavaRename<space>')
                call util#vimmap
                            \('nnoremap <buffer>','<leader>ji',':JavaImport<cr>')
                call util#vimmap
                            \('nnoremap <buffer>','<leader>jn',':JavaNew<space>')
                call util#vimmap
                            \('nnoremap <buffer>','<leader>jg',':JavaGet')
                call util#vimmap
                            \('nnoremap <buffer>','<leader>jc',':JavaConstructor<cr>')
                vnoremap <buffer> <leader>jc :JavaConstructor<cr>
                call util#vimmap
                            \('nnoremap <buffer>','<leader>jo',':JavaImportOrganize<cr>')
                call util#vimmap
                            \('nnoremap <buffer>','<leader>jm',':JavaMove<space>')
                if executable("ctags")
                    augroup CtagsJava
                        au!
                        autocmd  BufWritePost <buffer> call ctags#UpdateTags()
                    augroup END
                endif
                if v:vim_did_enter
                     call extensions#eclim#EclimGoToClassDeclarationLine()
                endif
            endif
        endif
    endif
endif
