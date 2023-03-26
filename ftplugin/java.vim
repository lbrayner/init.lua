" Command Declarations
command! -buffer -nargs=0 JavaBreakString
            \ call append(line("."),java#format#break_string(getline("."))) | delete
command! -buffer -nargs=0 -range JavaStringify
            \ <line1>,<line2>call java#format#stringify()
