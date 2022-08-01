" Command Declarations
command! -buffer -nargs=0 JavaBreakString
            \ call append(line("."),java#format#break_string(getline("."))) | delete
command! -buffer -nargs=0 -range JavaStringify
            \ <line1>,<line2>call java#format#stringify()

if util#EclimLoaded()
    if extensions#eclim#EclimAvailable()
        if eclim#project#util#GetCurrentProjectName() != ""
            command! -buffer -nargs=0 JavaPackage
                        \ let @"=eclim#java#util#GetPackage() |
                        \ let @+=@" | let @*=@" | echo @"
            command! -buffer -nargs=0 JavaGoToClassDeclaration
                        \ call extensions#eclim#EclimGoToClassDeclarationLine()
            command! -buffer -nargs=0 JavaQualifiedName
                       \ let @"=eclim#java#util#GetPackage().".".expand("%:t:r") |
                       \ let @+=@" | let @*=@" | echo @"
            nnoremap <buffer> <F11> :JavaCorrect<CR>
            nnoremap <buffer> gd :JavaSearch -x declarations<CR>
            nnoremap <buffer> gi :JavaSearch -x implementors<CR>
            nnoremap <buffer> gr :JavaSearch -x references<CR>
            if executable("ctags")
                augroup CtagsJava
                    autocmd!
                    autocmd BufWritePost <buffer> call ctags#UpdateTags()
                augroup END
            endif
            if v:vim_did_enter
                 call extensions#eclim#EclimGoToClassDeclarationLine()
            endif
        endif
    endif
endif
