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

function! util#GetComparableNodeName(filename)
    let node = resolve(substitute(fnamemodify(a:filename,":p"),'\','/','g'))
    let node = substitute(node,"/$","","")
    if has("win32") || has ("win64")
        return tolower(node)
    endif
    return node
endfunction

" TODO possibly remove this, for it's currently not used
" Based on tpope's vim-surround
function! util#getVisualSelection()
    let ve = &virtualedit
    set virtualedit=
    let reg = 'v'
    let reg_save = getreg(reg)
    let reg_type = getregtype(reg)
    silent exe 'norm! gv"'.reg.'y'
    let visual_selection = getreg(reg)
    call setreg(reg,reg_save,reg_type)
    let &virtualedit = ve
    return visual_selection
endfunction

function! s:truncateNode(filename,maxlength,...)
    if len(a:filename) <= a:maxlength
        return a:filename
    endif
    if len(fnamemodify(a:filename,":t")) < a:maxlength
        " -1 (forward slash), -3 (three dots)
        let trunc_fname_head=strpart(fnamemodify(a:filename,":h"),0,
                    \a:maxlength-len(fnamemodify(a:filename,":t"))-1-3)
        return trunc_fname_head.".../".fnamemodify(a:filename,":t")
    endif
    if a:0 > 0 && a:1
        if fnamemodify(a:filename,":e") != ""
            " -1 (a dot), -3 (three dots)
            let trunc_fname_tail=strpart(fnamemodify(a:filename,":t"),0,
                        \a:maxlength-len(fnamemodify(a:filename,":e"))-1-3)
            return trunc_fname_tail."....".fnamemodify(a:filename,":e")
        endif
    endif
    let trunc_fname_tail=strpart(fnamemodify(a:filename,":t"),0,a:maxlength-3)
    return trunc_fname_tail."..."
endfunction

function! util#truncateFilename(filename,maxlength,...)
    return s:truncateNode(a:filename,a:maxlength,1)
endfunction

function! util#truncateDirname(dirname,maxlength)
    return s:truncateNode(a:dirname,a:maxlength)
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

function! util#random()
    if &sh =~# 'sh'
        return system('echo $RANDOM')[:-2]
    endif
    if has("win32") || has("win64")
        if &sh =~# 'cmd.exe'
            return system('echo %RANDOM%')[:-2]
        endif
    endif
    return -1
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

function! util#getQuickfixTitle()
    return getqflist({"title": 1}).title
endfunction

function! util#getLocationListTitle(nr)
    return getloclist(a:nr, {"title": 1}).title
endfunction

function! util#IsVimBundle()
    return filereadable("init.vim")
endfunction

function! util#IsEclipseProject()
    return filereadable(".project")
endfunction

function! util#TabExists(tabnr)
    return len(gettabinfo(a:tabnr)) > 0
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
    return fnamemodify(a:path,":p:gs?\\?/?:s?/$??:~")
endfunction

" stridx is more efficient than substitute
function! util#IsInDirectory(directory, node)
    " Think Java's String.startsWith
    return stridx(util#NPath(a:node), util#NPath(a:directory)) == 0
endfunction

function! util#RelativeNode(directory, node)
    return substitute(util#NPath(a:node),'\V'.util#NPath(a:directory).'/\?',"","")
endfunction
