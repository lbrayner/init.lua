if !exists(":Delete")
    finish
endif

function s:DeleteReturnToAlternate(bang) abort
    let bang = a:bang ? "!" : ""
    if !bufexists(bufname("#"))
        exe "Delete".bang
        return
    endif
    exe "Unlink".bang
    b#
    bw #
endfunction

command! -bang -nargs=0 DeleteReturnToAlternate
            \ call s:DeleteReturnToAlternate(<bang>0)

" The Delete command is a noop and Remove, an alias to Delete

cnoreabbrev Delete echom "Oops! Not what I meant."
cnoreabbrev Remove DeleteReturnToAlternate
