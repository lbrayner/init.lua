" vim: sw=4
function! util#getSession()
    " vim-obsession
    let this_session=substitute(v:this_session, '\.\d\+\.obsession\~', "", "")
    " Is this a session?
    let session_name=this_session == "" ? "" : fnamemodify(this_session, ":t:r")
    return session_name
endfunction

function! util#setupMatchit()
    if exists("g:loaded_matchit")
        let b:match_ignorecase=0
        let b:match_words =
                    \  '<:>,' .
                    \  '<\@<=!\[CDATA\[:]]>,'.
                    \  '<\@<=!--:-->,'.
                    \  '<\@<=?\k\+:?>,'.
                    \  '<\@<=\([^ \t>/]\+\)\%(\s\+[^>]*\%([^/]>\|$\)\|>\|$\):<\@<=/\1>,'.
                    \  '<\@<=\%([^ \t>/]\+\)\%(\s\+[^/>]*\|$\):/>'
    endif
endfunction

function! util#truncateFilename(filename, maxlength)
    if len(a:filename) <= a:maxlength
        return a:filename
    endif
    let head = fnamemodify(a:filename, ":h")
    let tail = fnamemodify(a:filename, ":t")
    if head != "." && len(tail) < a:maxlength
        " -1 (forward slash), -1 (horizontal ellipsis …)
        return head[0:(a:maxlength - len(tail) - 1 - 1 - 1)]."…/".tail
    endif
    return tail[0:(a:maxlength/2 - 1)]."…".tail[(-(a:maxlength/2 - 1)):]
endfunction

" a string or a 0-arg funcref
function! util#PreserveViewPort(command)
    let lazyr = &lazyredraw
    try
        set lazyredraw
        let winview = winsaveview()
        if type(a:command) == type(function("tr"))
            call a:command()
        else
            exe a:command
        endif
        call winrestview(winview)
    finally
        let &lazyredraw = lazyr
    endtry
endfunction

function! util#isLocationList(...)
    let winid = win_getid()
    if a:0 && a:1
        let winid = a:1
    endif
    return getwininfo(winid)[0]["loclist"]
endfunction

function! util#isQuickfixList(...)
    let winid = win_getid()
    if a:0 && a:1
        let winid = a:1
    endif
    return getwininfo(winid)[0]["quickfix"] && !util#isLocationList(winid)
endfunction

function! util#isQuickfixOrLocationList(...)
    let winid = win_getid()
    if a:0 && a:1
        let winid = a:1
    endif
    return getwininfo(winid)[0]["quickfix"]
endfunction

function! util#getQuickfixOrLocationListTitle()
    if util#isLocationList()
        return getloclist(0, {"title": 1}).title
    endif
    return getqflist({"title": 1}).title
endfunction

function! util#WindowIsFloating()
    return nvim_win_get_config(0).relative != ""
endfunction

function! util#Options(...)
    if a:0 == 1
        if exists(a:1)
            exec "let value = ".a:1
            if value != ""
                return value
            endif
        endif
        return a:1
    endif
    if a:0 > 1
        for index in range(0,a:0-2)
            if exists(a:000[index])
                exec "let value = ".a:000[index]
                if value != ""
                    return value
                endif
            endif
        endfor
        " Default value (can be a constant, i.e. string or number)
        if exists(a:000[a:0-1])
            exec "let value = ".a:000[a:0-1]
            if value != ""
                return value
            endif
        endif
        return a:000[a:0-1]
    endif
endfunction

" Normalized path
" Recent versions of getcwd() return paths with backward slashes on win32
function util#NPath(path)
    return fnamemodify(a:path, ":p:gs?\\?/?:s?/$??:~")
endfunction

" stridx is more efficient than substitute
function! util#IsInDirectory(directory, node, ...)
    let directory = util#NPath(a:directory)
    let node = util#NPath(a:node)
    let exclusive = a:0 && a:1
    if exclusive && node == directory
        return 0
    endif
    " Think Java's String.startsWith
    return stridx(node, directory) == 0
endfunction

function! util#RelativeNode(directory, node)
    return substitute(util#NPath(a:node), '\V'.util#NPath(a:directory).'/\?', "", "")
endfunction
