" Vim syntax file
" Language:	BIRL
" Maintainer:	Leonardo Brayner e Silva
" Repository:   TODO
" License:      Vim

if exists("b:current_syntax")
  finish
endif

syn case ignore

syn keyword birlType	monstrinho monstro monstrao

syn match birlChar		display "frango"
syn match birlUnsigned	display "biceps frango"
syn match birlFloat		display "trapezio"
syn match birlDouble	display "trapezio descendente"
syn match birlWhile		display "negativa bambam"
syn match birlFor 		display "mais quero mais"
syn match birlContinue	display "vamo monstro"
syn match birlBreak		display "sai filho da puta"
syn match birlDefun 	display "oh o home ai po"
syn match birlCall 		display "ajuda o maluco ta doente"
syn match birlReturn 	display "bora cumpade"
syn match birlBegin		display "hora do show"
syn match birlEnd		display "birl"
syn match birlIf		display "ele que a gente quer?"
syn match birlElse		display "nao vai dar nao"
syn match birlElseIf	display "que nao vai dar o que?"
syn match birlPrint		display "ce quer ver essa porra?"
syn match birlRead		display "que que ce quer monstrao?"

" Numbers:
syn match birlNumber	"-\=\<\d*\.\=[0-9_]\>"

" Strings:
syn region birlString	matchgroup=Quote start=+n\?"+  skip=+\\\\\|\\"+  end=+"+

" Comments:
syn region birlComment	start="/\*"  end="\*/" contains=birlTodo,@Spell fold 
syn match birlComment	"//.*$" contains=birlTodo,@Spell

" Todo:
syn keyword birlTodo TODO FIXME XXX DEBUG NOTE contained

" Define the default highlighting.
hi def link Quote            Special
hi def link birlComment		Comment
hi def link birlFunction	Function
hi def link birlKeyword		birlSpecial
hi def link birlNumber		Number
" hi def link birlOperator	birlbirlSpecial
hi def link birlSpecial		Special
hi def link birlChar		Type
hi def link birlUnsigned	Type
hi def link birlDouble		Type
hi def link birlFloat		Type
hi def link birlBegin		birlSpecial
hi def link birlDefun		birlSpecial
hi def link birlEnd			birlSpecial
hi def link birlStatement	Statement
hi def link birlIf			birlSpecial
hi def link birlElse		birlSpecial
hi def link birlElseIf		birlSpecial
hi def link birlPrint		birlFunction
hi def link birlRead		birlFunction
hi def link birlReturn		birlStatement
hi def link birlCall		birlSpecial
hi def link birlWhile		birlSpecial
hi def link birlFor			birlSpecial
hi def link birlBreak		birlStatement
hi def link birlContinue	birlStatement
hi def link birlString		String
hi def link birlType		Type
hi def link birlTodo		Todo

let b:current_syntax = "birl"
