" file under the cursor

nnoremap <silent> <leader>fn
            \ :call miscellaneous#CopyFileNameUnderCursor()<cr>
nnoremap <silent> <leader>fp
            \ :call miscellaneous#CopyFileParentUnderCursor()<cr>
nnoremap <silent> <leader>ff
            \ :call miscellaneous#CopyFileFullPathUnderCursor()<cr>
nnoremap <silent> <leader>fr
            \ :call miscellaneous#CopyFilePathUnderCursor()<cr>

" other

vnoremap <silent> <leader><f3> :call miscellaneous#FilterVisualSelection()<cr>
vnoremap <silent> <leader><f4> :call miscellaneous#SourceVisualSelection()<cr>
vnoremap <silent> <leader>* <esc>:call miscellaneous#SearchLastVisualSelectionNoMagic()<cr>

if has("win32") || has("win64")
    nnoremap <silent> <leader><F3> :call miscellaneous#FilterLine()<cr>
endif

" XML

nnoremap <silent> [< :call miscellaneous#NavigateXmlDepthBackward(-v:count1)<cr>
nnoremap <silent> ]> :call miscellaneous#NavigateXmlDepth(-v:count1)<cr>

" Overlength

nnoremap <silent> <leader><f2> :call miscellaneous#HighlightOverLength()<cr>

" Save any buffer

command! -nargs=1 -bang -complete=file Save call miscellaneous#Save(<f-args>,<bang>0)
