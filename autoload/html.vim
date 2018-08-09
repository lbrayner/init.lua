function! s:LinkifyLine(line)
    return '<a href="'.a:line.'">'.a:line.'</a>'
endfunction

function! s:LinkifyList(lines)
    if empty(a:lines)
        return a:lines
    endif
    return [s:LinkifyLine(a:lines[0])] + s:LinkifyList(a:lines[1:])
endfunction

function! s:Linkify(text)
    let lines = split(a:text,"\n")
    return s:LinkifyList(lines)
endfunction

function! s:LinkifyLastVisualSelection()
    let last_visual_selection = util#getVisualSelection()
    return s:Linkify(last_visual_selection)
endfunction

function! html#linkify() range
    let line_start = a:firstline
    let line_end = a:lastline
    let lines = s:LinkifyLastVisualSelection()
    normal! gvd
    call append(a:firstline-1,lines)
endfunction
