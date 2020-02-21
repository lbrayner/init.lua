" CPF, CNPJ

function! all#format#CNPJFormat() range
    let range = a:firstline . ',' . a:lastline
    let text = getline(a:firstline)
    let regex = '\v<(\d{2})\.(\d{3})\.(\d{3})/(\d{4})-(\d{2})>'
    if text =~# regex
        exec range . 's#' . regex . '#\1\2\3\4\5#g'
        return
    endif
    exec range
        \ . 's#\v<(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})>#\1.\2.\3/\4-\5#g'
endfunction

function! all#format#CPFFormat() range
    let range = a:firstline . ',' . a:lastline
    let text = getline(a:firstline)
    let regex = '\v<(\d{3})\.(\d{3})\.(\d{3})-(\d{2})>'
    if text =~# regex
        exec range . 's#' . regex . '#\1\2\3\4#g'
        return
    endif
    exec range . 's#\v<(\d{3})(\d{3})(\d{3})(\d{2})>#\1.\2.\3-\4#g'
endfunction

" Time & Date

function! all#format#DmyYmdToggle() range
    let range = a:firstline . ',' . a:lastline
    let text = getline(a:firstline)
    let regex = '\v<(\d{2})-(\d{2})-(\d{4})>'
    if text =~# regex
        exec range . 's#' . regex . '#\3-\2-\1#g'
        return
    endif
    let regex = '\v<(\d{4})-(\d{2})-(\d{2})>'
    exec range . 's#' . regex . '#\3-\2-\1#g'
endfunction
