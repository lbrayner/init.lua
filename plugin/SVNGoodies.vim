if !executable('svn')
  finish
endif

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

function! s:SVNDiffCursor()
    let filename = expand("<cfile>")
    call s:SVNDiff(filename)
endfunction

function! s:SVNDiffThis()
    let filename = expand("%")
    call s:SVNDiff(filename)
endfunction

command! -nargs=0 SVNDiffCursor call s:SVNDiffCursor()
command! -nargs=0 SVNDiffThis call s:SVNDiffThis()

nnoremap <Plug>MVGSVNDiffCursor :call <SID>SVNDiffCursor()<CR>
