" flattened-solarized

if exists("g:disable_default_colorscheme") && g:disable_default_colorscheme
    finish
endif

let s:enable_solarized = 1

if !has("nvim") && !has("gui_running") && s:ssh_client
    let s:enable_solarized = 0
endif

if has("win32unix")
    let s:enable_solarized = 0
endif

if s:enable_solarized
    set cursorline
    colorscheme flattened_dark
    if exists("g:vim_did_enter")
        call statusline#initialize()
    endif
endif
