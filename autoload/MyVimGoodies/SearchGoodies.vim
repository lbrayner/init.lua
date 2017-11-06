" Adapted from
" https://www.reddit.com/r/vim/comments/1rzvsm/do_any_of_you_redirect_results_of_i_to_the/
"
" Show ]I and [I results in the quickfix window.
" See :help include-search.

function! MyVimGoodies#SearchGoodies#Ilist_loadQFWindow(selection,search_pattern,output)
    let lines = split(a:output, '\n')

    " better safe than sorry
    if lines[0] =~ '^Error detected'
        echomsg 'Could not find "' . (a:selection ? a:search_pattern : expand("<cword>")) . '".'
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
    call setqflist(qf_entries)

    " and we finally open the quickfix window if there's something to show
    cwindow
endfunction

function! MyVimGoodies#SearchGoodies#Ilist_getSearchPattern()
    let old_reg = @v
    normal! gv"vy
    let search_pattern = substitute(escape(@v, '\/.*$^~[]'), '\\n', '\\n', 'g')
    let @v = old_reg
    return search_pattern
endfunction

function! MyVimGoodies#SearchGoodies#VimGrep(selection,word,...)
    if a:selection
        let search_pattern = MyVimGoodies#SearchGoodies#Ilist_getSearchPattern()
    else
        let expand_exp = a:word ? "<cword>" : "<cWORD>"
        let search_pattern = expand(expand_exp)
    endif
    let paths = ""
    let command = "vimgrep /".search_pattern."/ "
    if len(a:000) > 0
        for entry in a:000
            let paths = paths.entry
        endfor
    else
        let paths = "**"
    endif
    exec command.paths
endfunction

function! MyVimGoodies#SearchGoodies#Ilist_qf(selection, start_at_cursor)

    " we are working with visually selected text
    if a:selection

        " there's a file associated with this buffer
        if len(expand('%')) > 0

            " and we redirect the output of our command for later use
            let search_pattern = MyVimGoodies#SearchGoodies#Ilist_getSearchPattern()
            redir => output
                silent! execute (a:start_at_cursor ? '+,$' : '') . 'ilist /' . search_pattern
            redir END

            call MyVimGoodies#SearchGoodies#Ilist_loadQFWindow(selection,search_pattern,output)

        else

            let search_pattern = MyVimGoodies#SearchGoodies#Ilist_getSearchPattern()
            " and we try to perform the search
            try
                execute (a:start_at_cursor ? '+,$' : '') . 'ilist /' .  search_pattern . '<CR>:'
            catch
                echomsg 'Could not find "' . search_pattern . '".'
                return
            endtry

        endif
    else
        if len(expand('%')) > 0
            " we redirect the output of our command for later use
            redir => output
                silent! execute 'normal! ' . (a:start_at_cursor ? ']' : '[') . "I"
            redir END

            call MyVimGoodies#SearchGoodies#Ilist_loadQFWindow(0,v:null,output)

        else

            " we try to perform the search
            try
                execute 'normal! ' . (a:start_at_cursor ? ']' : '[') . "I"
            catch
                echomsg 'Could not find "' . expand("<cword>") . '".'
                return
            endtry

        endif
    endif
endfunction
