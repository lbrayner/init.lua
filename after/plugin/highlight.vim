" TODO delete
DimInactiveOff

" https://gist.github.com/ctaylo21/c3620a945cee6fc3eb3cb0d7f57faf00
" Background colors for inactive windows
execute "highlight NormalNC ctermbg=".
            \statusline#themes#getColor("x236_Grey19","cterm").
            \" guibg=" . statusline#themes#getColor("x236_Grey19","gui")

function! s:DimInactiveBuftypeExceptions()
    if &buftype =~# '\v(nofile|nowrite|acwrite|quickfix|help)'
        setlocal winhighlight=NormalNC:NONE
    endif
endfunction

augroup DimInactiveExceptions
  autocmd!
  autocmd VimEnter * autocmd DimInactiveExceptions
              \ BufWinEnter * call s:DimInactiveBuftypeExceptions()
augroup END
