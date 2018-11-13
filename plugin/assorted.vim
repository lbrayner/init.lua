command! -range=% RemoveTrailingSpaces
            \ <line1>,<line2>call assorted#RemoveTrailingSpaces()

" dictionaries
command! -nargs=1 SetDictionaryLanguage
            \ call assorted#SetDictionaryLanguage(0,<f-args>)
command! -nargs=1 SetGlobalDictionaryLanguage
            \ call assorted#SetDictionaryLanguage(1,<f-args>)

" file under the cursor

nnoremap <silent> <leader>fn
            \ :call assorted#CopyFileNameUnderCursor()<cr>
nnoremap <silent> <leader>fp
            \ :call assorted#CopyFileParentUnderCursor()<cr>
nnoremap <silent> <leader>ff
            \ :call assorted#CopyFileFullPathUnderCursor()<cr>
nnoremap <silent> <leader>fr
            \ :call assorted#CopyFilePathUnderCursor()<cr>

"diff

nnoremap <silent> <leader>do :diffoff!<cr>

" other

vnoremap <silent> <leader><f3> :call assorted#FilterVisualSelection()<cr>
vnoremap <silent> <leader><f4> :call assorted#SourceVisualSelection()<cr>
vnoremap <silent> <leader>* <esc>:call assorted#SearchLastVisualSelectionNoMagic()<cr>

if has("win32")
    nnoremap <silent> <leader><F3> :call assorted#FilterLine()<cr>
endif

" XML

nnoremap <silent> [< :<c-u>call assorted#NavigateXmlDepth(-v:count1)<cr>

" overlength

nnoremap <silent> <leader><f2> :call assorted#HighlightOverLength()<cr>

" idle

augroup InsertModeUndoPoint
    autocmd!
    autocmd CursorHoldI * call assorted#InsertModeUndoPoint() 
augroup END
