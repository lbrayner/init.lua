command! -range=% RemoveTrailingSpaces
            \ <line1>,<line2>call AssortedGoodies#RemoveTrailingSpaces()

" dictionaries
command! -nargs=1 SetDictionaryLanguage
            \ call AssortedGoodies#SetDictionaryLanguage(0,<f-args>)
command! -nargs=1 SetGlobalDictionaryLanguage
            \ call AssortedGoodies#SetDictionaryLanguage(1,<f-args>)
