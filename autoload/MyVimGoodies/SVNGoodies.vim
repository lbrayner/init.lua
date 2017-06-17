let s:DiffTabMessage = 'q to close this tab.'

function! s:SVNDiff(filename)
    let tempfile = system("svn diff -r HEAD " . shellescape(a:filename)
                \ . " --diff-cmd ~/bin/svnmkpatch > /dev/null")
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

function! MyVimGoodies#SVNGoodies#SVNDiffCursor()
    let filename = expand("<cfile>")
    call s:SVNDiff(filename)
endfunction

function! MyVimGoodies#SVNGoodies#SVNDiffThis()
    let filename = expand("%")
    call s:SVNDiff(filename)
endfunction
