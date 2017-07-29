syn include @mailHighlighthtml syntax/html.vim
unlet! b:current_syntax

syn region mailHighlighthtml matchgroup=mailCodeDelimiter start="#=-=-=-=-=-=-=-=-=-" end="-=-=-=-=-=-=-=-=-=#" keepend contains=@mailHighlighthtml
