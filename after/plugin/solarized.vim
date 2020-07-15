" flattened-solarized

function! s:Solarized()
    set cursorline
    colorscheme flattened_dark
    if exists("g:vim_did_enter")
        call statusline#initialize()
    endif
    execute "highlight ColorColumn ctermbg="
                \. statusline#themes#getColor("x236_Grey19","cterm")
                \. " guibg=" . statusline#themes#getColor("x236_Grey19","gui")
endfunction

command! Solarized call s:Solarized()

let s:enable_solarized = 1

if !has("nvim") && !has("gui_running")
            \ && exists("g:ssh_client") && g:ssh_client
    let s:enable_solarized = 0
endif

if has("win32unix")
    let s:enable_solarized = 0
endif

if exists("g:disable_solarized")
    let s:enable_solarized = !g:disable_solarized
endif

if s:enable_solarized
    call s:Solarized()
endif
