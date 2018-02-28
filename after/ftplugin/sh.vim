" mappings
imapclear <buffer>
if exists('g:paredit_loaded')
    inoremap <buffer> <expr> " PareditInsertQuotes()
endif
