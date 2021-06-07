" user[:dbname]@(host|srvname)[:port] in the statusline
function! s:define_local_statusline()
    if exists("b:dbext_user")
        let b:Statusline_custom_rightline = ' %7*%{b:dbext_type}:%{b:dbext_user}'
                    \.'%{statusline#extensions#dbext#dbext_var("b:dbext_dbname")}@'
                    \.'%{util#Options("b:dbext_host","b:dbext_srvname","localhost")}'
                    \.'%{statusline#extensions#dbext#dbext_var("b:dbext_port")}%*'
                    \ . statusline#GetStatusLineTail()
        let b:Statusline_custom_mod_rightline = ' %7*%{b:dbext_type}:%{b:dbext_user}'
                    \.'%{statusline#extensions#dbext#dbext_var("b:dbext_dbname")}@'
                    \.'%{util#Options("b:dbext_host","b:dbext_srvname","localhost")}'
                    \.'%{statusline#extensions#dbext#dbext_var("b:dbext_port")}%*'
                    \ . statusline#GetStatusLineTail()
    endif
endfunction

autocmd BufWinEnter <buffer> call s:define_local_statusline()
