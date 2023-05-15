" http://vim.wikia.com/wiki/Run_a_command_in_multiple_buffers
" Tweaked by me to preserve last accessed tab
function! tab#TabDo(command)
    let current_tab=tabpagenr()
    exe "normal! g\<Tab>"
    let previous_tab=tabpagenr()
    try
        execute "tabdo " . a:command
    finally
        execute "tabn " . previous_tab
        execute "tabn " . current_tab
    endtry
endfunction

" https://superuser.com/a/555047
function! tab#TabcloseRight(bang)
    let currrentTab = tabpagenr()
    let ei = &eventignore
    set eventignore+=TabClosed
    while currrentTab < tabpagenr("$")
        exe "tabclose" . a:bang . " " . (currrentTab + 1)
    endwhile
    let &eventignore = ei
endfunction

function! tab#TabcloseLeft(bang)
    let ei = &eventignore
    set eventignore+=TabClosed
    while tabpagenr() > 1
        exe "tabclose" . a:bang . " 1"
    endwhile
    let &eventignore = ei
endfunction

function! tab#Tabonly(bang)
    let ei = &eventignore
    set eventignore+=TabClosed
    exe "tabonly" . a:bang
    let &eventignore = ei
endfunction

function! tab#Tabclose(bang)
    let ei = &eventignore
    set eventignore+=TabClosed
    exe "tabclose" . a:bang
    let &eventignore = ei
endfunction

function! tab#TabcloseRange(bang, from, to)
    call v:lua.require'lbrayner.tab'.tab_close_range(a:bang, str2nr(a:from), str2nr(a:to))
endfunction
