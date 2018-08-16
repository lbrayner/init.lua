" mappings
imapclear <buffer>
if exists('g:paredit_loaded')
    inoremap <buffer> <expr> " PareditInsertQuotes()
endif

" static snippets
abclear <buffer>
inoreabbrev <buffer> blk {<cr>}<c-o>O<tab>
inoreabbrev <buffer> forl for()<cr>{<cr>}<up><up><c-o>f(<right>
inoreabbrev <buffer> iff if()<cr>{<cr>}<up><up><c-o>f(<right>
iabbrev <buffer> printf sprintf("")<c-o>F"
inoreabbrev <buffer> fmt printf
