function! MyVimGoodies#TabGoodies#GoToTab()
    exe "tabs"
    let tab = input("Go to tab (" . tabpagenr() . "): ")
    if tab == ""
        return
    endif
    exe "tabn " . tab
endfunction

function! MyVimGoodies#TabGoodies#GoToLastTab()
    if ! exists("g:MyVimGoodies#TabGoodies#lasttab")
        let g:MyVimGoodies#TabGoodies#lasttab = tabpagenr()
    endif
    exe "tabn " . g:MyVimGoodies#TabGoodies#lasttab
endfunction
