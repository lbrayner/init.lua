command! -bar -range=% RemoveTrailingSpaces
            \ call util#PreserveViewPort('keeppatterns '.<line1>.','.<line2>.'s/\s\+$//e')

" dictionaries
command! -nargs=1 SetDictionaryLanguage
            \ call miscellaneous#SetDictionaryLanguage(0,<f-args>)
command! -nargs=1 SetGlobalDictionaryLanguage
            \ call miscellaneous#SetDictionaryLanguage(1,<f-args>)

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

" format

command! -range -nargs=0 CNPJFormat <line1>,<line2>call format#CNPJFormat()
command! -range -nargs=0 CPFFormat <line1>,<line2>call format#CPFFormat()
command! -range -nargs=0 DmyYmdToggle <line1>,<line2>call format#DmyYmdToggle()
command! -bar AllLowercase call util#PreserveViewPort('keeppatterns %s/.*/\L&/g')

" Save any buffer

command! -nargs=1 -bang -complete=file Save call miscellaneous#Save(<f-args>,<bang>0)
