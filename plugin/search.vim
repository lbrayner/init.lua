command! -nargs=* -bang VimGrepCursor call search#VimGrep(0,<bang>1,<f-args>)
command! -range -complete=file -nargs=* VimGrepSelection call search#VimGrep(1,v:null,<f-args>)

nnoremap <unique> <silent> [I :call search#Ilist_qf(0, 0)<CR>
nnoremap <unique> <silent> ]I :call search#Ilist_qf(0, 1)<CR>

" nnoremap <silent> [w :call search#VimGrep(0,1)<CR>
" nnoremap <silent> [W :call search#VimGrep(0,0)<CR>
" vnoremap <silent> [* :<C-u>call search#VimGrep(1)<CR>
" vnoremap ]* :<c-u>VimGrepSelection 
" xnoremap <silent> [I :<C-u>call Ilist_qf(1, 0)<CR>
" xnoremap <silent> ]I :<C-u>call Ilist_qf(1, 1)<CR>
"
call util#vimmap('nnoremap <silent>','[w',':call search#VimGrep(0,1)<CR>')
call util#vimmap('nnoremap <silent>','[W',':call search#VimGrep(0,0)<CR>')
call util#vimmap('vnoremap <silent>','[*',':call search#VimGrep(1,v:null)<CR>')
call util#vimmap('vnoremap',']*',':<c-u>VimGrepSelection ')
