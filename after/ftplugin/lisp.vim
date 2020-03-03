" emacs lisp
if tolower(expand("%:e")) == "el"
    cnoreabbrev <buffer> Rg Ack -g !elpa -g !github -g !srecode-map.el
                \ -g !auto-save-list -g !abbrev_defs -g !bookmarks
                \<S-Left><S-Left><S-Left><S-Left><S-Left><S-Left>
                \<S-Left><S-Left><S-Left><S-Left><S-Left><S-Left>
                \<left>
endif
