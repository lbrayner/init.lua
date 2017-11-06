function! MyVimGoodies#util#vimmap(leftside,keyseq,keyseqtarget)
    if ! hasmapto(a:keyseqtarget)
        exec a:leftside." "a:keyseq." "a:keyseqtarget
    endif
endfunction

function! MyVimGoodies#util#escapeFileName(filename)
    return substitute(a:filename, '\', '/', 'g')
endfunction

function! MyVimGoodies#util#getVisualSelection()
    let old_reg = @v
    normal! gv"vy
    let visual_selection = @v
    let @v = old_reg
    return visual_selection
endfunction
