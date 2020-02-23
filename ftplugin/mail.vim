if exists("b:my_did_ftplugin")
    finish
endif
let b:my_did_ftplugin = 1

if &ft == 'mail'
    setlocal completefunc=email#EmailComplete
    " Buffer local CursorMoved & CursorMovedI autocommands are deleted
    autocmd! CursorMoved,CursorMovedI <buffer>
    autocmd CursorMoved,CursorMovedI <buffer> call mail#mail_textwidth()
endif
