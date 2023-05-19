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
    call ripgrep#lrg('"^(<<<<<<<|\|\|\|\|\|\|\||=======|>>>>>>>)" ' . shellescape(bufname(a:bufnr)))
    if len(getloclist(0))
        augroup ConflictMarkers
        augroup END
        call s:ClearConflictMarkersAutocmd(a:bufnr)
        autocmd ConflictMarkers BufWritePost <buffer> call s:MaybeUpdateConflictMarkers(str2nr(expand("<abuf>")))
        autocmd ConflictMarkers WinEnter <buffer> call s:MaybeUpdateConflictMarkers(str2nr(expand("<abuf>")))
        call setloclist(0, [], "a", {"title": "Conflict markers"})
    endif
endfunction

function! s:ClearConflictMarkersAutocmd(bufnr)
    silent! exe "autocmd! ConflictMarkers BufWritePost,WinEnter <buffer=" . a:bufnr . ">"
endfunction

function! s:MaybeUpdateConflictMarkers(bufnr)
    if bufnr() != a:bufnr
        return
    endif
    if getloclist(winnr(), { "title": 1 }).title ==# "Conflict markers"
        let qfbufnr = getloclist(0, {"qfbufnr": 1}).qfbufnr
        if getbufvar(qfbufnr, "conflict_marker_tick") < b:changedtick
            call s:UpdateConflictMarkers(a:bufnr)
            call setbufvar(qfbufnr, "conflict_marker_tick", b:changedtick)
        endif
    endif
endfunction

function! s:ConflictMarkers(bufnr)
    call s:UpdateConflictMarkers(a:bufnr)
    if len(getloclist(0))
        let changedtick = b:changedtick
        lopen
        let b:conflict_marker_tick = changedtick
    else
        echo "No conflict markers found."
    endif
endfunction

command! -nargs=0 ConflictMarkers call s:ConflictMarkers(bufnr())
