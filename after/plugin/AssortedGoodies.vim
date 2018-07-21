" file under the cursor

call util#vimmap('nnoremap <silent>','<leader>fn'
            \ ,':call AssortedGoodies#CopyFileNameUnderCursor()<cr>')
call util#vimmap('nnoremap <silent>','<leader>fp'
            \ ,':call AssortedGoodies#CopyFileParentUnderCursor()<cr>')
call util#vimmap('nnoremap <silent>','<leader>ff'
            \ ,':call AssortedGoodies#CopyFileFullPathUnderCursor()<cr>')
call util#vimmap('nnoremap <silent>','<leader>fr'
            \ ,':call AssortedGoodies#CopyFilePathUnderCursor()<cr>')

"diff

call util#vimmap('nnoremap <silent>','<leader>do',':diffoff!<cr>')

" other

call util#vimmap('vnoremap <silent>','<leader><f3>'
            \ ,':call AssortedGoodies#FilterVisualSelection()<cr>')

call util#vimmap('vnoremap <silent>','<leader><f4>'
            \ ,':call AssortedGoodies#SourceVisualSelection()<cr>')

" XML

call util#vimmap('nnoremap <silent>','[<'
            \ ,':<c-u>call AssortedGoodies#NavigateXmlDepth(-v:count1)<cr>')

" overlength

nnoremap <silent> <leader><f2> :call AssortedGoodies#HighlightOverLength()<cr>

" idle

augroup InsertModeUndoPoint
    autocmd!
    autocmd CursorHoldI * call AssortedGoodies#InsertModeUndoPoint() 
augroup END
