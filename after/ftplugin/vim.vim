if !exists('g:FerretLoaded') || !g:FerretLoaded
    finish
endif

" Ignore submodules when searching the dotvim folder
" Ignore documentation
if executable("rg")
    cnoreabbrev <buffer> Rg Ack -g !pack -g !doc<S-Left><S-Left><left>
endif
