" Ignore submodules when searching the dotvim folder
" Ignore documentation
if executable("rg")
    cnoreabbrev <buffer> Rg Rg -g !pack -g !doc<S-Left><S-Left><S-Left><S-Left><left>
endif
