function! util#GetComparableNodeName(filename)
    let node = resolve(substitute(fnamemodify(a:filename,":p"),'\','/','g'))
    let node = substitute(node,"/$","","")
    if has("win32") || has ("win64")
        return tolower(node)
    endif
    return node
endfunction

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

function! util#trivialHorizontalMotion()
    let col = getpos('.')[2]
    if col <= 1
        return 'h'
    endif
    return 'lh'
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

function! util#getTempDirectory()
    let tempfile = tempname()
    return fnamemodify(tempfile,':h:h')
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

function! util#IsVimBundle()
    return filereadable("init.vim")
endfunction

function! util#IsEclipseProject()
    return filereadable(".project")
endfunction

function! util#TabExists(tabnr)
    return len(gettabinfo(a:tabnr)) > 0
endfunction

" Adapted from
" https://www.reddit.com/r/vim/comments/1rzvsm/do_any_of_you_redirect_results_of_i_to_the/
function! util#Ilist_Search(start_at_cursor,search_pattern,loclist,open)
    redir => output
        silent! execute (a:start_at_cursor ? '+,$' : '') . 'ilist! /' . a:search_pattern
    redir END

    let lines = split(output, '\n')

    " better safe than sorry
    if lines[0] =~ '^Error detected'
        echomsg 'Could not find "' . a:search_pattern . '".'
        return
    endif

    " we retrieve the filename
    let [filename, line_info] = [lines[0], lines[1:-1]]

    " we turn the :ilist output into a quickfix dictionary
    let qf_entries = map(line_info, "{
                \ 'filename': filename,
                \ 'lnum': split(v:val)[1],
                \ 'text': getline(split(v:val)[1])
                \ }")

    if a:loclist
        let set_list = "call setloclist(0,qf_entries)"
        let open_list = "lwindow"
        let go_to_first_entry = "lrewind"
    else
        let set_list = "call setqflist(qf_entries)"
        let open_list = "cwindow"
        let go_to_first_entry = "crewind"
    endif

    exec set_list

    if a:open
        exec open_list
    else
        exec go_to_first_entry
        normal! zz
    endif
endfunction
