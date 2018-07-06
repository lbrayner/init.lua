let g:java#format#length = 80

function! java#format#break_string(code)
    return format#break_string('\','"',"+",g:java#format#length,a:code)
endfunction

function! java#format#stringify() range
    silent exec "keepp ".a:firstline.",".a:lastline.'s/"/\\"/ge'
    if a:firstline == a:lastline
        silent exec "keepp ".a:firstline.",".a:firstline.'s/.*/"&"/e'
        return
    endif
    silent exec "keepp ".a:firstline.",".a:firstline.'s/.*/ "&"/e'
    silent exec "keepp ".(a:firstline+1).",".a:lastline.'s/.\+/+" &"/e'
endfunction
