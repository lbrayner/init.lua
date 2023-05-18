function! s:ToggleIWhite()
    if &l:diffopt =~# "iwhite"
        set diffopt-=iwhite
        echo "-iwhite"
        return
    endif
    set diffopt+=iwhite
    echo "+iwhite"
endfunction

" TODO turn these into commands?
nnoremap <Leader>di <Cmd>call <SID>ToggleIWhite()<CR>
nnoremap <Leader>do <Cmd>diffoff!<CR>

function! s:UpdateConflictMarkers(winid)
    let bufnr = getwininfo(a:winid)[0].bufnr
    call ripgrep#RgLL('"^(<<<<<<<|\|\|\|\|\|\|\||=======|>>>>>>>)"' . " " . shellescape(bufname(bufnr)),
                \"Conflict markers")
endfunction

function! s:ClearConflictMarkersAutocmd(winid)
    let bufnr = getwininfo(a:winid)[0].bufnr
    exe "autocmd! ConflictMarkers BufWritePost <buffer=" . bufnr . ">"
endfunction

function! s:MaybeUpdateConflictMarkers(winid)
    if !has_key(getloclist(win_id2win(a:winid), { "title": 1 }), "title")
        call s:ClearConflictMarkersAutocmd(a:winid)
        return
    endif
    if getloclist(win_id2win(a:winid), { "title": 1 }).title ==# "Conflict markers"
        call s:UpdateConflictMarkers(a:winid)
    else
        call s:ClearConflictMarkersAutocmd(a:winid)
    endif
endfunction

function! s:ConflictMarkers(winid)
    augroup ConflictMarkers
    augroup END
    call s:ClearConflictMarkersAutocmd(a:winid)
    exe "autocmd ConflictMarkers BufWritePost <buffer> call s:MaybeUpdateConflictMarkers(" . a:winid . ")"
    call s:UpdateConflictMarkers(a:winid)
endfunction

command! -nargs=0 ConflictMarkers call s:ConflictMarkers(win_getid())
