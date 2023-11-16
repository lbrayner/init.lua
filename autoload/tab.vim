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
