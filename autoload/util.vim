function! util#vimmap(leftside,keyseq,keyseqtarget)
    if ! hasmapto(a:keyseqtarget)
        exec a:leftside." "a:keyseq." "a:keyseqtarget
    endif
endfunction

function! util#escapeFileName(filename)
    return substitute(a:filename, '\', '/', 'g')
endfunction

" Based on tpope's vim-surround
function! util#getVisualSelection()
    let ve = &virtualedit
    set virtualedit=
    let reg = 'v'
    let reg_save = getreg(reg)
    let reg_type = getregtype(reg)
    silent exe 'norm! gv"'.reg.'y'
    let visual_selection = getreg(reg)
    call setreg(reg,reg_save,reg_type)
    let &virtualedit = ve
    return visual_selection
endfunction
