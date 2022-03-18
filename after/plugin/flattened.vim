function! s:SetupFlattened()
    set cursorline
    execute "highlight ColorColumn ctermbg="
                \. statusline#themes#getColor("x236_Grey19","cterm")
                \. " guibg=" . statusline#themes#getColor("x236_Grey19","gui")
endfunction

command! -nargs=0 SetupFlattened call s:SetupFlattened()

augroup FlattenedColorScheme
    autocmd!
    autocmd ColorScheme flattened_* call s:SetupFlattened()
augroup END

let s:enable = 1

if !has("nvim") && !has("gui_running")
            \ && exists("g:ssh_client") && g:ssh_client
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
