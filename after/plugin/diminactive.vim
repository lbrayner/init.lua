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

augroup DimInactiveExceptions
  autocmd!
  autocmd BufWinEnter * call s:DimInactiveBuftypeExceptions()
  autocmd VimEnter * autocmd DimInactiveExceptions
              \ WinLeave * call s:DimInactiveWindowExceptions()
    autocmd ColorScheme * call s:HighlightNormalNC()
augroup END

call s:HighlightNormalNC()

command! -nargs=0 HighlightNormalNC call s:HighlightNormalNC()
