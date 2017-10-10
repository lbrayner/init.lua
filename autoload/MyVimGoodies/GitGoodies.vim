let s:DiffTabMessage = 'q to close this tab.'

function! MyVimGoodies#GitGoodies#GitGetProjectRoot()
    let gitcommand = "git rev-parse --show-toplevel"
    let stdout = systemlist(gitcommand)
    if v:shell_error
        let message = stdout[0]
        throw message
    endif
    return stdout[0]
endfunction

function! MyVimGoodies#GitGoodies#GitStatus(...)
    try
        let projectroot = MyVimGoodies#GitGoodies#GitGetProjectRoot()
    catch /^fatal/
        echoerr v:exception
        return
    endtry
    let tempfile = MyVimGoodies#util#escapeFileName(tempname())
    let gitcommand = "git status"
    if a:0 > 0
        for extrarg in a:000
            let gitcommand = gitcommand . " " . extrarg
        endfor
    endif
    let oldir = getcwd()
    try
        exec "cd " . projectroot
        let stdout = systemlist(gitcommand)
        if v:shell_error
            let message = stdout[0]
            throw message
        endif
        call writefile(stdout,tempfile)
        let buffer_name = '['.fnamemodify(projectroot,':t').'] git-status'
        if bufexists(buffer_name)
            silent exe 'bwipe ' . fnameescape(buffer_name)
        endif
        silent exec ":split ".tempfile
              \ . ' | setlocal ft=git-status'
              \ . ' | setlocal noma'
              \ . ' | setlocal buftype=nofile'
              \ . ' | setlocal bufhidden=wipe'
              \ . ' | setlocal noswapfile'
              \ . ' | file '.buffer_name
              \ . ' | lcd '.projectroot
    catch /\v^fatal|^Error/
        echoerr message
    finally
        exec "cd " . oldir
        call delete(tempfile)
    endtry
endfunction

function! MyVimGoodies#GitGoodies#GitDiff(filename,...)
    try
        let projectroot = MyVimGoodies#GitGoodies#GitGetProjectRoot()
    catch /^fatal/
        echoerr v:exception
        return
    endtry
    let tempfile = MyVimGoodies#util#escapeFileName(tempname())
    let gitcommand = "git diff -R"
    if a:0 > 0
        for extrarg in a:000
            let gitcommand = gitcommand . " " . extrarg
        endfor
    endif
    let gitcommand = gitcommand . " " . shellescape(a:filename)
    let oldir = getcwd()
    try
        exec "cd " . projectroot
        let stdout = systemlist(gitcommand)
        if v:shell_error
            let message = stdout[0]
            throw message
        endif
        call writefile(stdout,tempfile)
        if getfsize(tempfile) != 0
            let s:current_tab = tabpagenr()
            silent exec ":tab sview ".a:filename." | sil lefta vert diffpa ".tempfile
                  \ . ' | exec "file ".expand("%:t")'
                  \ . ' | setlocal noma'
                  \ . ' | setlocal buftype=nofile'
                  \ . ' | setlocal bufhidden=wipe'
                  \ . ' | setlocal noswapfile'
                  \ . ' | nnoremap <silent> <buffer> <nowait> q :bw<cr>:tabc<cr>'
                  \         .s:current_tab.'gt'
                  \ . ' | autocmd WinEnter <buffer> echo "'.s:DiffTabMessage.'"'
        else
            echomsg "Contents equal HEAD."
        endif
    catch /\v^fatal|^Error/
        echoerr message
    finally
        exec "cd " . oldir
        call delete(tempfile)
    endtry
endfunction

function! MyVimGoodies#GitGoodies#GitDiffCursor(...)
    let vargs = copy(a:000)
    let filename = expand("<cfile>")
    call call(function("MyVimGoodies#GitGoodies#GitDiff"),insert(vargs,filename))
endfunction

function! MyVimGoodies#GitGoodies#GitDiffThis(...)
    let vargs = copy(a:000)
    let filename = expand("%")
    call call(function("MyVimGoodies#GitGoodies#GitDiff"),insert(vargs,filename))
endfunction

function! MyVimGoodies#GitGoodies#GitDiffContextual(...)
    let filename = expand("<cfile>")
    " echomsg filename
    let filename = MyVimGoodies#util#escapeFileName(fnamemodify(filename, ':p'))
    " echomsg filename
    if filereadable(filename)
        call MyVimGoodies#GitGoodies#GitDiffCursor(filename)
    else
        let filename = expand("%")
        let filename = MyVimGoodies#util#escapeFileName(fnamemodify(filename, ':p'))
        " echomsg filename
        call MyVimGoodies#GitGoodies#GitDiffThis(filename)
    endif
endfunction
