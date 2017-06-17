" nnoremap <silent> [w :call MyVimGoodies#SearchGoodies#VimGrep(0,1)<CR>
" nnoremap <silent> [W :call MyVimGoodies#SearchGoodies#VimGrep(0,0)<CR>
" vnoremap <silent> [* :<C-u>call MyVimGoodies#SearchGoodies#VimGrep(1)<CR>
" vnoremap ]* :<c-u>VimGrepSelection 
" xnoremap <silent> [I :<C-u>call Ilist_qf(1, 0)<CR>
" xnoremap <silent> ]I :<C-u>call Ilist_qf(1, 1)<CR>
"
call MyVimGoodies#util#vimmap('nnoremap <silent>','[w',':call MyVimGoodies#SearchGoodies#VimGrep(0,1)<CR>')
call MyVimGoodies#util#vimmap('nnoremap <silent>','[W',':call MyVimGoodies#SearchGoodies#VimGrep(0,0)<CR>')
call MyVimGoodies#util#vimmap('vnoremap <silent>','[*',':call MyVimGoodies#SearchGoodies#VimGrep(1,v:null)<CR>')
call MyVimGoodies#util#vimmap('vnoremap',']*',':<c-u>VimGrepSelection ')
