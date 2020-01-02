let s:DiffTabMessage = 'q to close this tab'

function! s:SVNDiff(filename)
    let tempdir = tempname()
    call mkdir(tempdir)
    let pristine = tempdir."/".fnamemodify(a:filename,":t")." (BASE)"
    let svncommand = "svn export -r BASE " . shellescape(a:filename)
                \ . " " . shellescape(pristine)
    try
        if !has("unix") && !has("win32")
            throw "Only unix and win32 supported."
        endif
        let stdout = systemlist(svncommand)
        if v:shell_error
            let message = stdout[0]
            throw message
        endif
        silent exec ":tabedit ".fnameescape(a:filename)
        let file_type = &filetype
        diffthis
        exec "silent leftabove vsplit ".fnameescape(pristine)
        if file_type != ""
            exec "setfiletype ".file_type
        endif
        diffthis
        setlocal nomodifiable
        setlocal buftype=nofile
        setlocal bufhidden=wipe
        setlocal noswapfile
        nnoremap <silent> <buffer> <nowait> q :bw<cr>:diffoff<cr>:tabc<cr>
        autocmd WinLeave <buffer> echo ""
        exe 'autocmd WinEnter <buffer> echo "'.s:DiffTabMessage.'"'
        wincmd w
    catch
        echoerr v:exception
    finally
        call delete(tempdir,"rf")
    endtry
endfunction

function! subversion#SVNDiffCursor()
    let filename = expand("<cfile>")
    call s:SVNDiff(filename)
endfunction

function! subversion#SVNDiffThis()
    let filename = expand("%")
    call s:SVNDiff(filename)
endfunction

function! subversion#SVNDiffContextual()
    let filename = expand("<cfile>")
    let filename = fnamemodify(filename,':p')
    if filereadable(filename)
        call subversion#SVNDiffCursor()
    else
        call subversion#SVNDiffThis()
    endif
endfunction
