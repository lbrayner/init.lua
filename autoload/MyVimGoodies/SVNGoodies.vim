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
        let message = substitute(tempfile,"[\r\n]","","g")
        echoerr message
        return
    endif
    if tempfile != ""
        silent exec ":tab sview ".a:filename." | sil lefta vert diffpa ".tempfile
                    \ . ' | setlocal noma | exec "file ".expand("%:t")'
                    \ . ' | nnoremap <silent> <buffer> <nowait> q :bw<cr>:tabc<cr>'
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
