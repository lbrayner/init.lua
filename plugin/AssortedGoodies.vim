" file under the cursor

function! s:CopyFileNameUnderCursor()
    silent exec ":let @\"=expand('<cfile>:t')"
    echomsg "Yanked file name."
endfunction

function! s:CopyFileParentUnderCursor()
    silent exec ":let @\"=expand('<cfile>:h')"
    echomsg "Yanked file's parent name."
endfunction

function! s:CopyFileFullPathUnderCursor()
    silent exec ":let @\"=expand('<cfile>:p')"
    echomsg "Yanked file's full path."
endfunction

function! s:CopyFilePathUnderCursor()
    silent exec ":let @\"=expand('<cfile>')"
    echomsg "Yanked file path."
endfunction

nnoremap <silent> 0fn :call <SID>CopyFileNameUnderCursor()<cr>
nnoremap <silent> 0fp :call <SID>CopyFileParentUnderCursor()<cr>
nnoremap <silent> 0ff :call <SID>CopyFileFullPathUnderCursor()<cr>
nnoremap <silent> 0fr :call <SID>CopyFilePathUnderCursor()<cr>

"diff

nnoremap <silent> 0do :diffoff!<cr>
