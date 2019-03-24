command! -nargs=* -bang VimGrepCursor call search#VimGrep(0,<bang>1,<f-args>)
command! -range -complete=file -nargs=* VimGrepSelection call search#VimGrep(1,v:null,<f-args>)
command! -nargs=1 SearchFileQF call search#Ilist_Search(0,<f-args>)

nnoremap <unique> <silent> [I :call search#Ilist_qf(0, 0)<CR>
nnoremap <unique> <silent> ]I :call search#Ilist_qf(0, 1)<CR>

nnoremap <silent>[w :call search#VimGrep(0,1)<CR>
nnoremap <silent>[W :call search#VimGrep(0,0)<CR>
vnoremap <silent>[* :call search#VimGrep(1,v:null)<CR>
vnoremap ]* :<c-u>VimGrepSelection<space>
