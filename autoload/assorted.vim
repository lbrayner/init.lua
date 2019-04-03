" highlight

highlight OverLength ctermbg=red ctermfg=white guibg=#592929

" file under the cursor

function! assorted#CopyFileNameUnderCursor()
    silent exec ":let @\"=expand('<cfile>:t')"
    echomsg "Yanked file name."
endfunction

function! assorted#CopyFileParentUnderCursor()
    silent exec ":let @\"=expand('<cfile>:h')"
    echomsg "Yanked file's parent name."
endfunction

function! assorted#CopyFileFullPathUnderCursor()
    silent exec ":let @\"=expand('<cfile>:p')"
    echomsg "Yanked file's full path."
endfunction

function! assorted#CopyFilePathUnderCursor()
    silent exec ":let @\"=expand('<cfile>')"
    echomsg "Yanked file path."
endfunction

function! assorted#SetDictionaryLanguage(global,language)
    if !exists("g:assorted#dictionaries")
        if exists("g:vim_did_enter")
            echoe "No dictionaries defined."
        endif
        return
    endif
    let dictionaries = g:assorted#dictionaries
    if a:global
        let &dictionary = dictionaries[a:language]
        return
    endif
    let &l:dictionary = dictionaries[a:language]
    echo "Dictionary language set to '" . a:language . "'."
endfunction

function! assorted#SourceVisualSelection() range
    let line_start = a:firstline
    let line_end = a:lastline
    let offset = 0
    for linenr in range(line_start,line_end)
        exe getline(linenr)
    endfor
    echom "Sourced visual selection."
endfunction

function! assorted#SearchLastVisualSelectionNoMagic()
    normal! gvy
    let pattern = escape(@",'\/')
    exe "normal! /\\V" . pattern
    let @/="\\V" . pattern
endfunction

function! assorted#FilterVisualSelection() range
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

function! assorted#RemoveTrailingSpaces() range
    silent exec "keepp ".a:firstline.",".a:lastline.'s/\s\+$//e'
endfunction

" XML

function! s:NavigateXmlNthParent(n)
    let n_command = "v" . (a:n+1) . "at"
    exec "silent normal! " . n_command . "v"
endfunction

function! assorted#NavigateXmlDepth(depth)
    if a:depth < 0
        call s:NavigateXmlNthParent(-a:depth)
        return
    endif
endfunction

function! assorted#HighlightOverLength()
    if ! exists("s:OverLength")
        let s:OverLength = 90
    endif
    if ! exists("w:HighlightOverLengthFlag")
        let w:HighlightOverLengthFlag = 1
    endif
    if w:HighlightOverLengthFlag
        exec 'match OverLength /\%' . s:OverLength . 'v.\+/'
        echo "Overlength highlighted."
    else
        exec "match"
        echo "Overlength highlight cleared."
    endif
    let w:HighlightOverLengthFlag = ! w:HighlightOverLengthFlag
endfunction

function! assorted#FilterLine()
    let line = getline('.')
    let temp = tempname()
    exe 'sil! !'.escape(line,&shellxescape).' > '.temp.' 2>&1'
    if v:shell_error
        exe 'throw "'.escape(readfile(temp)[0],'"').'"'
    endif
    exe "sil! read ".fnameescape(temp)
    exe "sil call delete ('".temp."')"
endfunction

" format

function! assorted#CNPJFormat() range
    let range = a:firstline . ',' . a:lastline
    let is_visual = len(range) != 0
    let text = getline(a:firstline)
    let regex = '\v<(\d{2})\.(\d{3})\.(\d{3})/(\d{4})-(\d{2})>'
    if text =~# regex
        exec range . 's#' . regex . '#\1\2\3\4\5#g'
        return
    endif
    exec range 
        \ . 's#\v<(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})>#\1.\2.\3/\4-\5#g'
endfunction

function! assorted#CPFFormat() range
    let range = a:firstline . ',' . a:lastline
    let is_visual = len(range) != 0
    let text = getline(a:firstline)
    let regex = '\v<(\d{3})\.(\d{3})\.(\d{3})-(\d{2})>'
    if text =~# regex
        exec range . 's#' . regex . '#\1\2\3\4#g'
        return
    endif
    exec range . 's#\v<(\d{3})(\d{3})(\d{3})(\d{2})>#\1.\2.\3-\4#g'
endfunction

" Save any buffer

function! assorted#Save(name)
    try
        let buf_nr = bufnr('%')
        set lazyredraw
        keepalt new
        silent! put =getbufline(buf_nr,1,'$')
        1d_
        exec "w " . fnameescape(a:name)
        exec bufwinnr(buf_nr)."wincmd w"
        quit
    finally
        set nolazyredraw
    endtry
endfunction
