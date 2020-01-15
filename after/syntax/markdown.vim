if !exists("b:current_syntax") || b:current_syntax != "markdown"
    finish
endif

hi link markdownH2 Type
hi link markdownH3 Underlined
hi link markdownH4 Identifier
hi link markdownH5 Statement
hi link markdownH6 Constant
