command! -nargs=* -bang VimGrepCursor call MyVimGoodies#SearchGoodies#VimGrep(0,<bang>1,<f-args>)
command! -range -complete=file -nargs=* VimGrepSelection call MyVimGoodies#SearchGoodies#VimGrep(1,v:null,<f-args>)

nnoremap <unique> <silent> [I :call MyVimGoodies#SearchGoodies#Ilist_qf(0, 0)<CR>
nnoremap <unique> <silent> ]I :call MyVimGoodies#SearchGoodies#Ilist_qf(0, 1)<CR>
