" user:dbname@(host|srvname) in the statusline
function! s:define_local_statusline()
    if exists("b:dbext_user")
        let b:Statusline_custom_rightline = ' %7*%{b:dbext_type}:%{b:dbext_user}'
                    \.':%{util#Options("b:dbext_dbname","b:dbext_user")}@'
                    \.'%{util#Options("b:dbext_host","b:dbext_srvname","localhost")}%*'
                    \ . statusline#GetStatusLineTail()
    endif
endfunction

autocmd BufWinEnter <buffer> call s:define_local_statusline()
