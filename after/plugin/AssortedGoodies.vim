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
            \ ,'<esc>:call MyVimGoodies#AssortedGoodies#FilterVisualSelection()<cr>')

" XML

call MyVimGoodies#util#vimmap('nnoremap <silent>','[<'
            \ ,':<c-u>call MyVimGoodies#AssortedGoodies#NavigateXmlDepth(-v:count1)<cr>')
