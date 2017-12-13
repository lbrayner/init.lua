command! -range=% RemoveTrailingSpaces
            \ <line1>,<line2>call MyVimGoodies#AssortedGoodies#RemoveTrailingSpaces()

command! -nargs=0 Qargs execute 'args! ' . MyVimGoodies#AssortedGoodies#QuickfixFilenames()
