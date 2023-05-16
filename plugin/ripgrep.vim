if !executable("rg")
    finish
endif

" From vim-ripgrep (https://github.com/lbrayner/vim-ripgrep)

set grepprg=rg\ --vimgrep
let &grepformat = "%f:%l:%c:%m"
let &shellpipe="&>"

function! s:RgOpts()
    let rgopts = " "
    if &ignorecase == 1
        let rgopts .= "-i "
    endif
    if &smartcase == 1
        let rgopts .= "-S "
    endif
    return rgopts
endfunction

function! s:RgLL(txt, ...)
    let rgopts = s:RgOpts()
    try
        " Escaping Command-line special characters '#', '%' (:h :_%), and '|' (:h :bar)
        silent exe "lgrep! " . rgopts . escape(a:txt, "#%|")
        if len(getloclist(0))
            if a:0 > 0
                call setloclist(0, [], "a", {"title": a:1})
            endif
            lopen
        else
            lclose
            echom "No match found for " . a:txt
        endif
    catch
        lclose
        echom "Error searching for " . a:txt . ". Unmatched quotes? Check your command."
    endtry
endfunction

function! s:RgQF(txt, ...)
    let rgopts = s:RgOpts()
    try
        " Escaping Command-line special characters '#', '%' (:h :_%), and '|' (:h :bar)
        silent exe "grep! " . rgopts . escape(a:txt, "#%|")
        if len(getqflist())
            if a:0 > 0
                call setqflist([], "a", {"title": a:1})
            endif
            botright copen
        else
            cclose
            echom "No match found for " . a:txt
        endif
    catch
        cclose
        echom "Error searching for " . a:txt . ". Unmatched quotes? Check your command."
    endtry
endfunction

command! -nargs=* -complete=file Rg :call s:RgQF(<q-args>)
cnoreabbrev Rb Rg -s '\b\b'<Left><Left><Left>
cnoreabbrev Rw Rg -s '\b<C-R><C-W>\b'

function! s:UpdateConflictMarkers(winid)
    let bufnr = getwininfo(a:winid)[0].bufnr
    call s:RgLL('"^(<<<<<<<|\|\|\|\|\|\|\||=======|>>>>>>>)"' . " " . shellescape(bufname(bufnr)),
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
