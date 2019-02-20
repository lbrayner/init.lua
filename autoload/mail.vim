" Line number specific text-width setting
" https://vi.stackexchange.com/a/9187

function! mail#mail_textwidth()
    if index(["mailHeaderKey", "mailSubject", "mailHeaderEmail",
                \ "mailHeader"], synIDattr(synID(line('.'), 1, 1),
                \ 'name')) >= 0
        if &textwidth != 0
            setlocal textwidth=0
        endif
    else
        if &textwidth != 72
            setlocal textwidth=72
        endif
    endif
endfun
