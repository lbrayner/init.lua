if empty(globpath(&rtp, "colors/flattened_dark.vim"))
    finish
endif

function! s:SetupFlattened()
    set cursorline
    hi QuickFixLine cterm=NONE ctermbg=8 ctermfg=13 guibg=#002b36 guifg=#6c71c4 gui=NONE
    " vim-diminactive
    execute "highlight ColorColumn ctermbg=".
                \statusline#themes#getColor("x236_Grey19","cterm").
                \" guibg=".statusline#themes#getColor("x236_Grey19","gui")
endfunction

command! -nargs=0 SetupFlattened call s:SetupFlattened()

augroup FlattenedColorScheme
    autocmd!
    autocmd ColorScheme flattened_* call s:SetupFlattened()
augroup END

let s:enable = 1

if !has("nvim") && !has("gui_running") &&
            \ exists("g:ssh_client") && g:ssh_client
    let s:enable = 0
endif

if has("win32unix")
    let s:enable = 0
endif

if exists("g:disable_flattened")
    let s:enable = !g:disable_flattened
endif

if s:enable
    colorscheme flattened_dark
endif
