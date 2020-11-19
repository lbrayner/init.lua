call util#setupMatchit()

setlocal completefunc=email#EmailComplete
" Buffer local CursorMoved & CursorMovedI autocommands are deleted
autocmd! CursorMoved,CursorMovedI <buffer>
autocmd CursorMoved,CursorMovedI <buffer> call mail#mail_textwidth()
