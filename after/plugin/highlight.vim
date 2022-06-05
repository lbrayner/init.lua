" TODO delete
DimInactiveOff

" https://gist.github.com/ctaylo21/c3620a945cee6fc3eb3cb0d7f57faf00
" Background colors for inactive windows
execute "highlight NormalNC ctermbg=".
            \statusline#themes#getColor("x236_Grey19","cterm").
            \" guibg=" . statusline#themes#getColor("x236_Grey19","gui")

function! s:DimInactiveBuftypeExceptions()
    if exists("b:dim_inactive") && b:dim_inactive
        return
    endif
    if &buftype =~# '\v%(nofile|nowrite|acwrite|quickfix|help)'
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

augroup DimInactiveExceptions
  autocmd!
  autocmd VimEnter * autocmd DimInactiveExceptions
              \ BufWinEnter * call s:DimInactiveBuftypeExceptions()
  autocmd VimEnter * autocmd DimInactiveExceptions
              \ WinLeave * call s:DimInactiveWindowExceptions()
augroup END
