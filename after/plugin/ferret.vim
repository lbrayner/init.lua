if !exists('g:FerretLoaded') || !g:FerretLoaded
    finish
endif

function! s:FerretRipgrepAbbreviation()
    if util#IsVimBundle()
        autocmd BufEnter <buffer> cnoreabbrev Rg Ack -g !pack<S-Left><S-Left><left>
    endif
endfunction

" ripgrep
if ferret#private#executable() =~# "^rg "
    augroup FerretAbbrevAutogroup
        autocmd!
        autocmd FileType vim call s:FerretRipgrepAbbreviation()
    augroup END
endif
