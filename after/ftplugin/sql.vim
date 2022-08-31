" user[:dbname]@(host|srvname)[:port] in the statusline
function! s:dbext_statusline()
    if exists("b:dbext_user")
        let b:Statusline_custom_rightline = '%9*%{b:dbext_type}:%{b:dbext_user}'
                    \.'%{statusline#extensions#dbext#dbext_var("b:dbext_dbname")}@'
                    \.'%{util#Options("b:dbext_host","b:dbext_srvname","localhost")}'
                    \.'%{statusline#extensions#dbext#dbext_var("b:dbext_port")}%* '
        let b:Statusline_custom_mod_rightline = '%9*%{b:dbext_type}:%{b:dbext_user}'
                    \.'%{statusline#extensions#dbext#dbext_var("b:dbext_dbname")}@'
                    \.'%{util#Options("b:dbext_host","b:dbext_srvname","localhost")}'
                    \.'%{statusline#extensions#dbext#dbext_var("b:dbext_port")}%* '
        call statusline#RedefineStatusLine()
    endif
endfunction

autocmd BufWinEnter <buffer> call s:dbext_statusline()
