" other

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
