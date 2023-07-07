if empty(globpath(&rtp, "colors/flattened_dark.vim"))
    finish
endif

function! s:SetupFlattened()
    set cursorline
    hi QuickFixLine cterm=NONE ctermbg=8 ctermfg=13 guibg=#002b36 guifg=#6c71c4 gui=NONE
    lua require("fzf-lua").setup_highlights()
endfunction

command! -nargs=0 SetupFlattened call s:SetupFlattened()

augroup FlattenedColorScheme
    autocmd!
    autocmd ColorScheme flattened_* call s:SetupFlattened()
augroup END

if !exists("g:disable_flattened")
    colorscheme flattened_dark
endif
