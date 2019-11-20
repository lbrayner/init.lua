if !exists("b:current_syntax") || b:current_syntax != "fugitive"
    finish
endif

hi link fugitiveUnstagedHeading Comment
hi link fugitiveStagedHeading Underlined
