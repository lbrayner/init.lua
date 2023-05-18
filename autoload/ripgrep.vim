" From vim-ripgrep (https://github.com/lbrayner/vim-ripgrep)

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

function! s:RgReady()
    if stridx(&grepprg, "rg") != 0
        throw "Rg: 'grepprg' not correctly set."
    endif
    if !executable("rg")
        throw "Rg: 'rg' not executable."
    endif
endfunction

" Location List
function! ripgrep#RgLL(txt, ...)
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

" Quickfix
function! ripgrep#RgQF(txt, ...)
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
