" other

vnoremap <silent> <leader>* <esc>:call miscellaneous#SearchLastVisualSelectionNoMagic()<cr>

" Overlength

nnoremap <silent> <leader><f2> :call miscellaneous#HighlightOverLength()<cr>

" Save any buffer

command! -nargs=1 -bang -complete=file Save call miscellaneous#Save(<f-args>,<bang>0)
