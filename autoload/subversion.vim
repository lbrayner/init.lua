let s:DiffTabMessage = 'q to close this tab.'

function! s:SVNDiff(filename,...)
    let escaped_filename = shellescape(a:filename)
    let svncommand = "svn diff " . escaped_filename
    if exists("g:MVGoodies_svn_diff_cmd")
        let svncommand = svncommand . " --diff-cmd " . g:MVGoodies_svn_diff_cmd
    else
        let svncommand = svncommand . " --internal-diff"
    endif
    if a:0 > 0
        for extrarg in a:000
            let svncommand = svncommand . " " . extrarg
        endfor
    endif
    let patch = util#escapeFileName(tempname())
    let reversed_patch = util#escapeFileName(tempname())
    try
        if !has("unix") && !has("win32")
            throw "Only unix and win32 supported."
        endif
        let stdout = systemlist(svncommand)
        if v:shell_error
            let message = stdout[0]
            throw message
        endif
        call writefile(stdout,patch)
        " On win32 use cygwin's interdiff
        let stdout = systemlist("interdiff " . patch . " /dev/null")
        if v:shell_error
            let message = stdout[0]
            throw message
        endif
        call writefile(stdout,reversed_patch)
        if getfsize(reversed_patch) != 0
            let s:current_tab = tabpagenr()
            silent exec ":tab sview ".a:filename." | sil lefta vert diffpa ".reversed_patch
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
    catch
        echoerr v:exception
    finally
        call delete(patch)
        call delete(reversed_patch)
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
