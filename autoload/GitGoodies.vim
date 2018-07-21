let s:DiffTabMessage = 'q to close this tab.'

function! GitGoodies#GitGetProjectRoot()
    let gitcommand = "git rev-parse --show-toplevel"
    let stdout = systemlist(gitcommand)
    if v:shell_error
        let message = stdout[0]
        throw message
    endif
    return stdout[0]
endfunction

function! GitGoodies#GitStatus(...)
    try
        let projectroot = GitGoodies#GitGetProjectRoot()
    catch /^fatal/
        echoerr v:exception
        return
    endtry
    let tempfile = util#escapeFileName(tempname())
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

function! GitGoodies#GitDiff(filename,...)
    try
        call GitGoodies#GitGetProjectRoot()
    catch /^fatal/
        echoerr v:exception
        return
    endtry
    let tempfile = util#escapeFileName(tempname())
    let gitcommand = "git -c core.fileMode=false diff -R --no-ext-diff"
    if a:0 > 0
        for extrarg in a:000
            let gitcommand = gitcommand . " " . extrarg
        endfor
    endif
    let gitcommand = gitcommand . " " . shellescape(a:filename)
    try
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
        call delete(tempfile)
    endtry
endfunction

function! GitGoodies#GitDiffCursor(...)
    let vargs = copy(a:000)
    let filename = expand("<cfile>")
    call call(function("GitGoodies#GitDiff"),insert(vargs,filename))
endfunction

function! GitGoodies#GitDiffThis(...)
    let vargs = copy(a:000)
    let filename = expand("%")
    call call(function("GitGoodies#GitDiff"),insert(vargs,filename))
endfunction

function! GitGoodies#GitDiffContextual(...)
    let filename = expand("<cfile>")
    " echomsg filename
    let filename = util#escapeFileName(fnamemodify(filename, ':p'))
    " echomsg filename
    if filereadable(filename)
        call GitGoodies#GitDiffCursor(filename)
    else
        let filename = expand("%")
        let filename = util#escapeFileName(fnamemodify(filename, ':p'))
        " echomsg filename
        call GitGoodies#GitDiffThis()
    endif
endfunction
