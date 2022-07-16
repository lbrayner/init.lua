" https://stackoverflow.com/a/2573758
" redir_messages.vim
"
" Inspired by the TabMessage function/command combo found
" at <http://www.jukie.net/~bart/conf/vimrc>.
"
function! s:RedirMessages(msgcmd)
    redir => message
    silent execute a:msgcmd
    redir END
    silent put=message
endfunction

" Example:
"
"   :RedirMessages echo "Key mappings for Control+A:" | map <C-A>
command! -nargs=+ -complete=command RedirMessages call s:RedirMessages(<q-args>)
