" file under the cursor

function! MyVimGoodies#AssortedGoodies#CopyFileNameUnderCursor()
    silent exec ":let @\"=expand('<cfile>:t')"
    echomsg "Yanked file name."
endfunction

function! MyVimGoodies#AssortedGoodies#CopyFileParentUnderCursor()
    silent exec ":let @\"=expand('<cfile>:h')"
    echomsg "Yanked file's parent name."
endfunction

function! MyVimGoodies#AssortedGoodies#CopyFileFullPathUnderCursor()
    silent exec ":let @\"=expand('<cfile>:p')"
    echomsg "Yanked file's full path."
endfunction

function! MyVimGoodies#AssortedGoodies#CopyFilePathUnderCursor()
    silent exec ":let @\"=expand('<cfile>')"
    echomsg "Yanked file path."
endfunction

function! MyVimGoodies#AssortedGoodies#FilterVisualSelection()
    let line_start = getpos("'<")[1]
    let line_end = getpos("'>")[1]
    let offset = 0
    for linenr in range(line_start,line_end)
        call cursor(linenr+offset,0)
        let output = systemlist(getline(linenr+offset))
        exe "delete"
        call append(linenr+offset-1,output)
        if len(offset) > 0
            let offset += len(output) - 1
        endif
    endfor
    call cursor(line_start,0)
endfunction

function! MyVimGoodies#AssortedGoodies#RemoveTrailingSpaces() range
    silent exec "keepp ".a:firstline.",".a:lastline.'s/\s\+$//e'
endfunction
