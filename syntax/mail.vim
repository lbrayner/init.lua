syn include @mailHighlighthtml syntax/html.vim
unlet! b:current_syntax

" syn region mailHighlighthtml matchgroup=mailCodeDelimiter start="^\s*```\s*html\>.*$" end="^\s*```\ze\s*$" keepend contains=@mailHighlighthtml
syn region mailHighlighthtml matchgroup=mailCodeDelimiter start="<html>" end="</html>" keepend contains=@mailHighlighthtml

hi def link mailCodeDelimiter         Delimiter

let maildotvim = rzip#util#escapeFileName($VIMRUNTIME).'/syntax/mail.vim'

exec "runtime! ".maildotvim
