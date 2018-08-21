" mappings
imapclear <buffer>
if exists('g:paredit_loaded')
    inoremap <buffer> <expr> " PareditInsertQuotes()
endif

" static snippets
abclear <buffer>
iabbrev <buffer> countall count(*)
inoreabbrev <buffer> countal countall
inoreabbrev <buffer> counta count()<left>
inoreabbrev <buffer> maxa max()<left>
inoreabbrev <buffer> mina min()<left>
inoreabbrev <buffer> suma sum()<left>
inoreabbrev <buffer> blk (<cr>)<c-o>O
