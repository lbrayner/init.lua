syn region gitHead start=/\%(^commit\%( \x\{4,40}\)\%(\s*(.*)\)\=$\)\@=/ end=/^$/
syn match  gitHashAbbrev /\<\x\{4,40\}\>/ containedin=gitHead contained
