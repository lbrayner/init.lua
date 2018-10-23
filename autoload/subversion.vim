let s:DiffTabMessage = 'q to close this tab.'

function! s:SVNDiff(filename,...)
    exec "let extension = fnamemodify('".a:filename."',':t:e')"
    let pristine = util#escapeFileName(tempname()).".".extension
    let escaped_filename = shellescape(a:filename)
    let svncommand = "svn export -r BASE " . escaped_filename . " " . pristine
    try
        if !has("unix") && !has("win32")
            throw "Only unix and win32 supported."
        endif
        let stdout = systemlist(svncommand)
        if v:shell_error
            let message = stdout[0]
            throw message
        endif
        if getfsize(pristine) != 0
            let s:current_tab = tabpagenr()
            silent exec ":tab sview ".a:filename." | diffthis "
                      \ . " | lefta vs ".pristine
                      \ . ' | diffthis '
                      \ . ' | exec "file ".fnamemodify("'.a:filename.'",":t")'
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
    catch
        echoerr v:exception
    finally
        call delete(pristine)
    endtry
endfunction

function! subversion#SVNDiffCursor(...)
    let vargs = copy(a:000)
    let filename = expand("<cfile>")
    call call(function("s:SVNDiff"),insert(vargs,filename))
endfunction

function! subversion#SVNDiffThis(...)
    let vargs = copy(a:000)
    let filename = expand("%")
    call call(function("s:SVNDiff"),insert(vargs,filename))
endfunction

function! subversion#SVNDiffContextual(...)
    let filename = expand("<cfile>")
    " echomsg filename
    let filename = util#escapeFileName(fnamemodify(filename, ':p'))
    " echomsg filename
    if filereadable(filename)
        call subversion#SVNDiffCursor()
    else
        let filename = expand("%")
        let filename = util#escapeFileName(fnamemodify(filename, ':p'))
        " echomsg filename
        call subversion#SVNDiffThis()
    endif
endfunction
