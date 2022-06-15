if !has("nvim")
    finish
endif

function! s:DimInactiveBuftypeExceptions()
    if exists("b:dim_inactive") && b:dim_inactive
        return
    endif
    if &buftype =~# '\v%(nofile|nowrite|acwrite|quickfix|help|terminal)'
        set winhighlight=NormalNC:NONE
        let b:dim_inactive = 1
    endif
endfunction

function! s:DimInactiveWindowExceptions()
    if exists("b:dim_inactive") && b:dim_inactive
        return
    endif
    if &diff
        set winhighlight=NormalNC:NONE
        return
    endif
    set winhighlight=
endfunction

" https://gist.github.com/ctaylo21/c3620a945cee6fc3eb3cb0d7f57faf00
" Background colors for inactive windows
function! s:HighlightNormalNC()
    execute "highlight NormalNC ctermbg=".
                \statusline#themes#getColor("x236_Grey19","cterm").
                \" guibg=".statusline#themes#getColor("x236_Grey19","gui")
endfunction

function! s:DimInactiveEnable()
    augroup DimInactive
      autocmd!
      autocmd BufWinEnter * call s:DimInactiveBuftypeExceptions()
      autocmd VimEnter * autocmd DimInactive
                  \ WinLeave * call s:DimInactiveWindowExceptions()
        autocmd ColorScheme * call s:HighlightNormalNC()
        autocmd User DimInactive call s:DimInactiveBuftypeExceptions()
    augroup END
    call s:HighlightNormalNC()
endfunction

function! s:DimInactiveDisable()
    augroup DimInactive
      autocmd!
    augroup END
    highlight clear NormalNC
endfunction

call s:DimInactiveEnable()

command! -nargs=0 HighlightNormalNC call s:HighlightNormalNC()
command! -nargs=0 DimInactiveEnable call s:DimInactiveEnable()
command! -nargs=0 DimInactiveDisable call s:DimInactiveDisable()
