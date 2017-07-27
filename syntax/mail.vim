syn include @mailHighlighthtml syntax/html.vim
unlet! b:current_syntax

syn region mailHighlighthtml matchgroup=mailCodeDelimiter start="<html>" end="</html>" keepend contains=@mailHighlighthtml

hi def link mailCodeDelimiter         Delimiter
