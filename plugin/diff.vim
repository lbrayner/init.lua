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

function! s:UpdateConflictMarkers(bufnr)
    call ripgrep#RgLL('"^(<<<<<<<|\|\|\|\|\|\|\||=======|>>>>>>>)"' . " " . shellescape(bufname(a:bufnr)),
                \"Conflict markers")
endfunction

function! s:ClearConflictMarkersAutocmd(bufnr)
    exe "autocmd! ConflictMarkers BufWritePost <buffer=" . a:bufnr . ">"
endfunction

function! s:MaybeUpdateConflictMarkers(bufnr)
    for winid in gettabinfo(tabpagenr())[0].windows
        if winbufnr(winid) == a:bufnr
            let winnr = win_id2win(winid)
            if empty(getloclist(winnr))
                continue
            endif
            if getloclist(winnr, { "title": 1 }).title ==# "Conflict markers"
                call win_execute(winid, "call s:UpdateConflictMarkers(" . a:bufnr . ")")
                return
            endif
        endif
    endfor
endfunction

function! s:ConflictMarkers(bufnr)
    augroup ConflictMarkers
    augroup END
    call s:ClearConflictMarkersAutocmd(a:bufnr)
    autocmd ConflictMarkers BufWritePost <buffer> call s:MaybeUpdateConflictMarkers(str2nr(expand("<abuf>")))
    call s:UpdateConflictMarkers(a:bufnr)
endfunction

command! -nargs=0 ConflictMarkers call s:ConflictMarkers(bufnr())
