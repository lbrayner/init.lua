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

function! MyVimGoodies#AssortedGoodies#SetDictionaryLanguage(global,language)
    if !exists("g:MyVimGoodies#AssortedGoodies#dictionaries")
        echoe "No dictionaries defined."
        return
    endif
    let dictionaries = g:MyVimGoodies#AssortedGoodies#dictionaries
    if a:global
        let &dictionary = dictionaries[a:language]
        return
    endif
    let &l:dictionary = dictionaries[a:language]
    echo "Dictionary language set to '" . a:language . "'."
endfunction

function! MyVimGoodies#AssortedGoodies#SourceVisualSelection() range
    let line_start = a:firstline
    let line_end = a:lastline
    let offset = 0
    for linenr in range(line_start,line_end)
        exe getline(linenr)
    endfor
    echom "Sourced visual selection."
endfunction

function! MyVimGoodies#AssortedGoodies#FilterVisualSelection() range
    let line_start = a:firstline
    let line_end = a:lastline
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

" XML

function! s:NavigateXmlNthParent(n)
    let n_command = "v" . (a:n+1) . "at"
    exec "silent normal! " . n_command . "v"
    exec "silent normal! \<esc>"
endfunction

function! MyVimGoodies#AssortedGoodies#NavigateXmlDepth(depth)
    if a:depth < 0
        call s:NavigateXmlNthParent(-a:depth)
        return
    endif
endfunction

function! MyVimGoodies#AssortedGoodies#HighlightOverLength()
    if ! exists("s:OverLength")
        let s:OverLength = 90
    endif
    if ! exists("w:HighlightOverLengthFlag")
        let w:HighlightOverLengthFlag = 1
    endif
    if w:HighlightOverLengthFlag
        highlight OverLength ctermbg=red ctermfg=white guibg=#592929
        exec 'match OverLength /\%' . s:OverLength . 'v.\+/'
        echo "Overlength highlighted."
    else
        exec "match"
        echo "Overlength highlight cleared."
    endif
    let w:HighlightOverLengthFlag = ! w:HighlightOverLengthFlag
endfunction

function! MyVimGoodies#AssortedGoodies#InsertModeUndoPoint()
    if mode() != "i"
        return
    endif
    call feedkeys("\<c-g>u")
endfunction
