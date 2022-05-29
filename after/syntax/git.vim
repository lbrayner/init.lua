" vim: textwidth=0

syn region gitHead start=/\%(^commit\%( \x\{4,40}\)\%(\s*(.*)\)\=$\)\@=/ end=/^$/
syn match  gitKeyword /^\%(object\|type\|tag\|commit\|tree\|parent\|encoding\)\>/ contained containedin=gitHead nextgroup=gitHash,gitHashAbbrev,gitType skipwhite
