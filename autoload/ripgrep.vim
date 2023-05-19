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

function! s:rg(txt, ...)
    let command = "grep"
    if a:0 > 0 && a:1
        let command = "lgrep"
    endif
    let rgopts = s:RgOpts()
    call s:RgReady()
    " Escaping Command-line special characters '#', '%' (:h :_%), and '|' (:h :bar)
    silent exe command . "! " . rgopts . escape(a:txt, "#%|")
endfunction

" Location List
function! ripgrep#lrg(txt)
    call s:rg(a:txt, 1)
endfunction

" Quickfix
function! ripgrep#rg(txt)
    call s:rg(a:txt)
endfunction
