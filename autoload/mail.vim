" Line number specific text-width setting
" https://vi.stackexchange.com/a/9187

function! mail#mail_textwidth()
    if index(["mailHeaderKey", "mailSubject", "mailHeaderEmail",
                \ "mailHeader"], synIDattr(synID(line('.'), col('.'), 1),
                \ 'name')) >= 0
        setlocal textwidth=500
    else
        setlocal textwidth=72
    endif
endfun
