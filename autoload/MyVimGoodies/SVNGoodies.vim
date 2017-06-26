let s:DiffTabMessage = 'q to close this tab.'

function! s:SVNDiff(filename,...)
    let svncommand = "svn diff -r HEAD " . shellescape(a:filename)
                \ . " --diff-cmd ~/bin/svnmkpatch"
    if a:0 > 0
        for extrarg in a:000
            let svncommand = svncommand . " " . extrarg
        endfor
    endif
    let svncommand = svncommand . " > /dev/null"
    let tempfile = system(svncommand)
    if v:shell_error
        let message = substitute(tempfile,"[\r]","","g")
        echoerr message
        return
    endif
    if tempfile != ""
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
endfunction

function! MyVimGoodies#SVNGoodies#SVNDiffCursor(...)
    let vargs = copy(a:000)
    let filename = expand("<cfile>")
    call call(function("s:SVNDiff"),insert(vargs,filename))
endfunction

function! MyVimGoodies#SVNGoodies#SVNDiffThis(...)
    let vargs = copy(a:000)
    let filename = expand("%")
    call call(function("s:SVNDiff"),insert(vargs,filename))
endfunction

function! MyVimGoodies#SVNGoodies#SVNDiffContextual(...)
    let filename = expand("<cfile>")
    " echomsg filename
    let filename = MyVimGoodies#util#escapeFileName(fnamemodify(filename, ':p'))
    " echomsg filename
    if filereadable(filename)
        call MyVimGoodies#SVNGoodies#SVNDiffCursor()
    else
        let filename = expand("%")
        let filename = MyVimGoodies#util#escapeFileName(fnamemodify(filename, ':p'))
        " echomsg filename
        call MyVimGoodies#SVNGoodies#SVNDiffThis(filename)
    endif
endfunction
