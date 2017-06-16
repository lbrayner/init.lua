" Adapted from
" https://www.reddit.com/r/vim/comments/1rzvsm/do_any_of_you_redirect_results_of_i_to_the/
"
" Show ]I and [I results in the quickfix window.
" See :help include-search.

function! s:Ilist_loadQFWindow(selection,search_pattern,output)
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

function! s:Ilist_getSearchPattern()
    let old_reg = @v
    normal! gv"vy
    let search_pattern = substitute(escape(@v, '\/.*$^~[]'), '\\n', '\\n', 'g')
    let @v = old_reg
    return search_pattern
endfunction

function! s:VimGrep(selection,...)
    if a:selection
        let search_pattern = s:Ilist_getSearchPattern()
    else
        let search_pattern = expand("<cword>")
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

function! s:Ilist_qf(selection, start_at_cursor)

    " we are working with visually selected text
    if a:selection

        " there's a file associated with this buffer
        if len(expand('%')) > 0

            " and we redirect the output of our command for later use
            let search_pattern = s:Ilist_getSearchPattern()
            redir => output
                silent! execute (a:start_at_cursor ? '+,$' : '') . 'ilist /' . search_pattern
            redir END

            call s:Ilist_loadQFWindow(selection,search_pattern,output)

        else

            let search_pattern = s:Ilist_getSearchPattern()
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

            call s:Ilist_loadQFWindow(0,v:null,output)

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

command! -nargs=1 VimGrep call s:VimGrep(1,<f-args>)

nnoremap <silent> [I :call <SID>Ilist_qf(0, 0)<CR>
nnoremap <silent> ]I :call <SID>Ilist_qf(0, 1)<CR>

nnoremap <silent> [* :call <SID>VimGrep(0)<CR>
vnoremap <silent> [* :<C-u>call <SID>VimGrep(1)<CR>
" xnoremap <silent> [I :<C-u>call Ilist_qf(1, 0)<CR>
" xnoremap <silent> ]I :<C-u>call Ilist_qf(1, 1)<CR>
