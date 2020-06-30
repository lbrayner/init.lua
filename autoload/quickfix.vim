" Adapted from
" https://www.reddit.com/r/vim/comments/1rzvsm/do_any_of_you_redirect_results_of_i_to_the/
function! quickfix#ilist_search(start_at_cursor,search_pattern,loclist,open)
    redir => output
        silent! execute (a:start_at_cursor ? '+,$' : '') . 'ilist! /' . a:search_pattern
    redir END

    let lines = split(output, '\n')

    " better safe than sorry
    if lines[0] =~ '^Error detected'
        echomsg 'Could not find "' . a:search_pattern . '".'
        return
    endif

    " we retrieve the filename
    let [filename, line_info] = [lines[0], lines[1:-1]]

    " we turn the :ilist output into a quickfix dictionary
    let qf_entries = map(line_info, "{
                \ 'filename': filename,
                \ 'lnum': split(v:val)[1],
                \ 'text': getline(split(v:val)[1])
                \ }")

    if a:loclist
        let set_list = "call setloclist(0,qf_entries)"
        let open_list = "lwindow"
        let go_to_first_entry = "lrewind"
    else
        let set_list = "call setqflist(qf_entries)"
        let open_list = "cwindow"
        let go_to_first_entry = "crewind"
    endif

    exec set_list

    if a:open
        exec open_list
    else
        exec go_to_first_entry
        normal! zz
    endif
endfunction
