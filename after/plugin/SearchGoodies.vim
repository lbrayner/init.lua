" nnoremap <silent> [w :call SearchGoodies#VimGrep(0,1)<CR>
" nnoremap <silent> [W :call SearchGoodies#VimGrep(0,0)<CR>
" vnoremap <silent> [* :<C-u>call SearchGoodies#VimGrep(1)<CR>
" vnoremap ]* :<c-u>VimGrepSelection 
" xnoremap <silent> [I :<C-u>call Ilist_qf(1, 0)<CR>
" xnoremap <silent> ]I :<C-u>call Ilist_qf(1, 1)<CR>
"
call util#vimmap('nnoremap <silent>','[w',':call SearchGoodies#VimGrep(0,1)<CR>')
call util#vimmap('nnoremap <silent>','[W',':call SearchGoodies#VimGrep(0,0)<CR>')
call util#vimmap('vnoremap <silent>','[*',':call SearchGoodies#VimGrep(1,v:null)<CR>')
call util#vimmap('vnoremap',']*',':<c-u>VimGrepSelection ')
