if !exists("b:current_syntax") || b:current_syntax != "fugitive"
    finish
endif

hi link fugitiveUntrackedHeading Comment
hi link fugitiveStagedHeading Underlined
