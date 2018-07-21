function! g:IncrementVariable(var)
    exe "let ".a:var." = ".a:var." + 1"
    exe "let to_return = ".a:var
    return to_return
endfunction
