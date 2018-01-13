" http://vim.wikia.com/wiki/Run_a_command_in_multiple_buffers
function! MyVimGoodies#TabGoodies#TabDo(command)
  let currTab=tabpagenr()
  execute 'tabdo ' . a:command
  execute 'tabn ' . currTab
endfunction

function! s:PrintTabs()
    echohl WarningMsg
    echo tabpagenr() " " . fnamemodify(getcwd(),":~")
    echohl None
    for window in gettabinfo(tabpagenr())[0]["windows"]
        echo "\t" . fnamemodify(getbufinfo(getwininfo(window)[0]["bufnr"])[0]["name"]
                    \,":~:.")
    endfor
endfunction

function! MyVimGoodies#TabGoodies#GoToTab()
    echo "Current tabs:"
    call MyVimGoodies#TabGoodies#TabDo("call s:PrintTabs()")
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
