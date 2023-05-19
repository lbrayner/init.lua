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
function! ripgrep#RgLL(txt)
    let rgopts = s:RgOpts()
    call s:RgReady()
    " Escaping Command-line special characters '#', '%' (:h :_%), and '|' (:h :bar)
    silent exe "lgrep! " . rgopts . escape(a:txt, "#%|")
endfunction

" Quickfix
function! ripgrep#RgQF(txt)
    let rgopts = s:RgOpts()
    call s:RgReady()
    " Escaping Command-line special characters '#', '%' (:h :_%), and '|' (:h :bar)
    silent exe "grep! " . rgopts . escape(a:txt, "#%|")
endfunction
