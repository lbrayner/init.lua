" https://gist.github.com/ctaylo21/c3620a945cee6fc3eb3cb0d7f57faf00
" Background colors for active vs inactive windows
execute "highlight InactiveWindow ctermbg=".
            \ statusline#themes#getColor("x236_Grey19","cterm").
            \ " guibg=" . statusline#themes#getColor("x236_Grey19","gui")

" Call method on window enter
augroup WindowManagement
  autocmd!
  autocmd WinEnter * call Handle_Win_Enter()
augroup END

" Change highlight group of active/inactive windows
function! Handle_Win_Enter()
  setlocal winhighlight=NormalNC:InactiveWindow
endfunction
