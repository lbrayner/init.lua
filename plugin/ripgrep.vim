if !executable("rg")
    finish
endif

set grepprg=rg\ --vimgrep
let &grepformat = "%f:%l:%c:%m"
let &shellpipe="&>"

" From vim-ripgrep (https://github.com/lbrayner/vim-ripgrep)
function! s:Rg(txt)
    let l:rgopts = " "
    if &ignorecase == 1
        let l:rgopts = l:rgopts . "-i "
    endif
    if &smartcase == 1
        let l:rgopts = l:rgopts . "-S "
    endif
    try
        " Escaping Command-line special characters '#', '%' (:h :_%), and '|' (:h :bar)
        silent exe "grep! " . l:rgopts . escape(a:txt, "#%|")
        if len(getqflist())
            botright copen
        else
            cclose
            echom "No match found for " . a:txt
        endif
    catch
        cclose
        echom "Error searching for " . a:txt . ". Check your command."
    endtry
endfunction

command! -nargs=* -complete=file Rg :call s:Rg(<q-args>)
cnoreabbrev Rw Rg -s '\b\b'<Left><Left><Left><C-R><C-W>
