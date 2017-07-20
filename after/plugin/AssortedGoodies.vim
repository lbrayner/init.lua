" file under the cursor

" nnoremap <silent> 0fn :call MyVimGoodies#AssortedGoodies#CopyFileNameUnderCursor()<cr>
" nnoremap <silent> 0fp :call MyVimGoodies#AssortedGoodies#CopyFileParentUnderCursor()<cr>
" nnoremap <silent> 0ff :call MyVimGoodies#AssortedGoodies#CopyFileFullPathUnderCursor()<cr>
" nnoremap <silent> 0fr :call MyVimGoodies#AssortedGoodies#CopyFilePathUnderCursor()<cr>

call MyVimGoodies#util#vimmap('nnoremap <silent>','<leader>fn'
            \ ,':call MyVimGoodies#AssortedGoodies#CopyFileNameUnderCursor()<cr>')
call MyVimGoodies#util#vimmap('nnoremap <silent>','<leader>fp'
            \ ,':call MyVimGoodies#AssortedGoodies#CopyFileParentUnderCursor()<cr>')
call MyVimGoodies#util#vimmap('nnoremap <silent>','<leader>ff'
            \ ,':call MyVimGoodies#AssortedGoodies#CopyFileFullPathUnderCursor()<cr>')
call MyVimGoodies#util#vimmap('nnoremap <silent>','<leader>fr'
            \ ,':call MyVimGoodies#AssortedGoodies#CopyFilePathUnderCursor()<cr>')

"diff

" nnoremap <silent> 0do :diffoff!<cr>
call MyVimGoodies#util#vimmap('nnoremap <silent>','<leader>do',':diffoff!<cr>')
