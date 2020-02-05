" flattened-solarized

function! s:DefaultColorscheme()
    set cursorline
    colorscheme flattened_dark
    if exists("g:vim_did_enter")
        call statusline#initialize()
    endif
    execute "highlight ColorColumn ctermbg="
                \. statusline#themes#getColor("x236_Grey19","cterm")
                \. " guibg=" . statusline#themes#getColor("x236_Grey19","gui")
endfunction

command! DefaultColorscheme call s:DefaultColorscheme()

if exists("g:disable_default_colorscheme") && g:disable_default_colorscheme
    finish
endif

let s:enable_default_colorscheme = 1

if !has("nvim") && !has("gui_running")
            \ && exists("g:ssh_client") && g:ssh_client
    let s:enable_default_colorscheme = 0
endif

if has("win32unix")
    let s:enable_default_colorscheme = 0
endif

if s:enable_default_colorscheme
    call s:DefaultColorscheme()
endif
