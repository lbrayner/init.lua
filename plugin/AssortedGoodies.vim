command! -range=% RemoveTrailingSpaces
            \ <line1>,<line2>call assorted#RemoveTrailingSpaces()

" dictionaries
command! -nargs=1 SetDictionaryLanguage
            \ call assorted#SetDictionaryLanguage(0,<f-args>)
command! -nargs=1 SetGlobalDictionaryLanguage
            \ call assorted#SetDictionaryLanguage(1,<f-args>)
