function! MyVimGoodies#util#vimmap(leftside,keyseq,rightside)
    if ! hasmapto(a:keyseq)
        exec a:leftside." "a:keyseq." "a:rightside
    endif
endfunction
