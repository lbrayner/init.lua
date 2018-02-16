" file under the cursor

call MyVimGoodies#util#vimmap('nnoremap <silent>','<leader>fn'
            \ ,':call MyVimGoodies#AssortedGoodies#CopyFileNameUnderCursor()<cr>')
call MyVimGoodies#util#vimmap('nnoremap <silent>','<leader>fp'
            \ ,':call MyVimGoodies#AssortedGoodies#CopyFileParentUnderCursor()<cr>')
call MyVimGoodies#util#vimmap('nnoremap <silent>','<leader>ff'
            \ ,':call MyVimGoodies#AssortedGoodies#CopyFileFullPathUnderCursor()<cr>')
call MyVimGoodies#util#vimmap('nnoremap <silent>','<leader>fr'
            \ ,':call MyVimGoodies#AssortedGoodies#CopyFilePathUnderCursor()<cr>')

"diff

call MyVimGoodies#util#vimmap('nnoremap <silent>','<leader>do',':diffoff!<cr>')

" other

call MyVimGoodies#util#vimmap('vnoremap <silent>','<leader><f3>'
            \ ,':call MyVimGoodies#AssortedGoodies#FilterVisualSelection()<cr>')

call MyVimGoodies#util#vimmap('vnoremap <silent>','<leader><f4>'
            \ ,':call MyVimGoodies#AssortedGoodies#SourceVisualSelection()<cr>')

" XML

call MyVimGoodies#util#vimmap('nnoremap <silent>','[<'
            \ ,':<c-u>call MyVimGoodies#AssortedGoodies#NavigateXmlDepth(-v:count1)<cr>')

" overlength

nnoremap <silent> <leader><f2> :call MyVimGoodies#AssortedGoodies#HighlightOverLength()<cr>

" idle

augroup InsertModeUndoPoint
    autocmd!
    autocmd CursorHoldI * call MyVimGoodies#AssortedGoodies#InsertModeUndoPoint() 
augroup END
