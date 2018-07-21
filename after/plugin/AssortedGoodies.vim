" file under the cursor

call util#vimmap('nnoremap <silent>','<leader>fn'
            \ ,':call assorted#CopyFileNameUnderCursor()<cr>')
call util#vimmap('nnoremap <silent>','<leader>fp'
            \ ,':call assorted#CopyFileParentUnderCursor()<cr>')
call util#vimmap('nnoremap <silent>','<leader>ff'
            \ ,':call assorted#CopyFileFullPathUnderCursor()<cr>')
call util#vimmap('nnoremap <silent>','<leader>fr'
            \ ,':call assorted#CopyFilePathUnderCursor()<cr>')

"diff

call util#vimmap('nnoremap <silent>','<leader>do',':diffoff!<cr>')

" other

call util#vimmap('vnoremap <silent>','<leader><f3>'
            \ ,':call assorted#FilterVisualSelection()<cr>')

call util#vimmap('vnoremap <silent>','<leader><f4>'
            \ ,':call assorted#SourceVisualSelection()<cr>')

" XML

call util#vimmap('nnoremap <silent>','[<'
            \ ,':<c-u>call assorted#NavigateXmlDepth(-v:count1)<cr>')

" overlength

nnoremap <silent> <leader><f2> :call assorted#HighlightOverLength()<cr>

" idle

augroup InsertModeUndoPoint
    autocmd!
    autocmd CursorHoldI * call assorted#InsertModeUndoPoint() 
augroup END
