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
    call setloclist(0, [], "a", {"title": "Conflict markers"})
endfunction

function! s:ClearConflictMarkersAutocmd(bufnr)
    exe "autocmd! ConflictMarkers BufWritePost <buffer=" . a:bufnr . ">"
endfunction

function! s:MaybeUpdateConflictMarkers(bufnr)
    if bufnr() != a:bufnr
        return
    endif
    if getloclist(winnr(), { "title": 1 }).title ==# "Conflict markers"
        if !exists("b:conflict_marker_tick") || b:conflict_marker_tick < b:changedtick
            let b:conflict_marker_tick = b:changedtick
        else
            return
        endif
        call s:UpdateConflictMarkers(a:bufnr)
    endif
endfunction

function! s:ConflictMarkers(bufnr)
    augroup ConflictMarkers
    augroup END
    call s:ClearConflictMarkersAutocmd(a:bufnr)
    autocmd ConflictMarkers BufWritePost <buffer> call s:MaybeUpdateConflictMarkers(str2nr(expand("<abuf>")))
    autocmd ConflictMarkers WinEnter <buffer> call s:MaybeUpdateConflictMarkers(str2nr(expand("<abuf>")))
    call s:UpdateConflictMarkers(a:bufnr)
    if len(getloclist(0))
        lopen
    else
        echo "No conflict markers found."
    endif
endfunction

command! -nargs=0 ConflictMarkers call s:ConflictMarkers(bufnr())
