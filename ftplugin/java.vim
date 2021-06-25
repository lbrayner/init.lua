" Command Declarations
command! -buffer JavaBreakString
            \ :call append(line("."),java#format#break_string(getline("."))) | delete
command! -buffer -range JavaStringify
            \ <line1>,<line2>call java#format#stringify()

if util#EclimLoaded()
    if extensions#eclim#EclimAvailable()
        let projectName = eclim#project#util#GetCurrentProjectName()
        if projectName != ""
            let s:eclim = 1
            nnoremap <buffer> <leader>P
                       \ :let @"=eclim#java#util#GetPackage()<cr>
                        \:let @+=@"<cr>
                        \:let @*=@"<cr>
                        \:echo @"<cr>
            nnoremap <buffer> <silent> <leader>C
                        \ :call extensions#eclim#EclimGoToClassDeclarationLine()<cr>
            nnoremap <buffer> <leader>F
                       \ :let @"=eclim#java#util#GetPackage().".".expand("%:t:r")<cr>
                        \:let @+=@"<cr>:let @*=@"<cr>:echo @"<cr>
            nnoremap <buffer> <leader>js :JavaSearch<space>
            nnoremap <buffer> <leader>jr :JavaRename<space>
            nnoremap <buffer> <leader>ji :JavaImport<cr>
            nnoremap <buffer> <leader>jn :JavaNew<space>
            nnoremap <buffer> <leader>jg :JavaGet
            vnoremap <buffer> <leader>jg :JavaGet
            nnoremap <buffer> <leader>jc :JavaConstructor<cr>
            vnoremap <buffer> <leader>jc :JavaConstructor<cr>
            nnoremap <buffer> <leader>jo :JavaImportOrganize<cr>
            nnoremap <buffer> <leader>jm :JavaMove<space>
            nnoremap <buffer> <F11> :JavaCorrect<CR>
            nnoremap <buffer> <leader><F11> :JavaSearchContext<CR>
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
