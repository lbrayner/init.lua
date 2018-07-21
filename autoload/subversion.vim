let s:DiffTabMessage = 'q to close this tab.'

function! s:SVNDiff(filename,...)
    let escaped_filename = shellescape(a:filename)
    let svncommand = "svn diff --old=" . escaped_filename
            \ . " --new=" . escaped_filename . "@HEAD"
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
    let tempfile = util#escapeFileName(tempname())
    try
        let stdout = systemlist(svncommand)
        if v:shell_error
            let message = stdout[0]
            echoerr message
            return
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
    finally
        call delete(tempfile)
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
