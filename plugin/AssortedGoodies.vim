command! -range=% RemoveTrailingSpaces
            \ <line1>,<line2>call MyVimGoodies#AssortedGoodies#RemoveTrailingSpaces()

" dictionaries
command! -nargs=1 SetDictionaryLanguage
            \ call MyVimGoodies#AssortedGoodies#SetDictionaryLanguage(0,<f-args>)
command! -nargs=1 SetGlobalDictionaryLanguage
            \ call MyVimGoodies#AssortedGoodies#SetDictionaryLanguage(1,<f-args>)
