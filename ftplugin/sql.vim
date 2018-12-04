if exists("b:my_did_ftplugin")
    finish
endif
let b:my_did_ftplugin = 1

if &ft == 'sql'
    " Command Declarations
    command! -buffer SqlBreakString
                \ :call append(line("."),sql#format#break_string(getline("."))) | delete
endif

" delimitMate

let b:delimitMate_matchpairs = "(:)"
