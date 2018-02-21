command! JavaBreakString :call append(line("."),java#format#break_string(getline(".")))
            \ | delete
