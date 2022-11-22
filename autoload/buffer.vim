"Based on BufOnly.vim

function! s:MessageBuffers(buffer_count)
	if a:buffer_count == 1
		echomsg a:buffer_count "buffer wiped"
	elseif a:buffer_count > 1
		echomsg a:buffer_count "buffers wiped"
	endif
endfunction

function! s:WipeBuffers(predicate,...)
    let buffer_count = s:LoopBuffers(a:predicate.
                \" && getbufvar(n,'&buftype') !=# 'terminal'",
                \a:0 > 0 ? a:1 : 0,a:0 > 1 ? a:2 : 0)
    call s:MessageBuffers(buffer_count)
endfunction

" TODO using getbufinfo, review predicates
function! s:LoopBuffers(predicate,bang,silent)
	let buffer_count = 0
    let bang = a:bang ? "!" : ""
    let ei = &eventignore
    set eventignore+=TabClosed
    for buf in getbufinfo()
        let n = buf.bufnr
        if eval(a:predicate)
            let command = "bwipe" . bang . " " . n
            if a:silent
                " Ignore errors
                silent! exe command
            else
                silent exe command
            endif
            let buffer_count += 1
        endif
    endfor
    let &eventignore = ei
    return buffer_count
endfunction

function! buffer#BWipe(pattern)
    let s:wipe_pattern = a:pattern
    call s:WipeBuffers('buflisted(n) && bufname(n) =~# s:wipe_pattern')
endfunction

function! buffer#BWipeFileType(...)
    if a:0 > 0
        let s:filetype = a:1
    else
        let s:filetype = &ft
    endif
    call s:WipeBuffers('getbufvar(n,"&ft") == s:filetype')
endfunction

function! buffer#BWipeHidden(pattern)
    if a:pattern == ""
        call s:WipeBuffers('getbufinfo(n)[0].hidden')
        return
    endif
    let s:wipe_pattern = a:pattern
    call s:WipeBuffers('bufname(n) =~# s:wipe_pattern && getbufinfo(n)[0].hidden')
endfunction

function! buffer#BWipeNotLoaded()
    call s:WipeBuffers('buflisted(n) && !bufloaded(n)')
endfunction

function! buffer#BWipeForce(pattern)
    let s:wipe_pattern = a:pattern
    call s:WipeBuffers('buflisted(n) && bufname(n) =~#'
                \ . ' s:wipe_pattern',1,1)
endfunction

function! buffer#BWipeForceUnlisted(pattern)
    let s:wipe_pattern = a:pattern
    call s:WipeBuffers('!buflisted(n) && bufname(n) =~#'
                \ . ' s:wipe_pattern',1,1)
endfunction

function! buffer#BWipeNotReadable()
    call s:WipeBuffers('buflisted(n) && !filereadable(bufname(n))')
endfunction

function! buffer#BWipeNotReadableForce()
    call s:WipeBuffers('buflisted(n) && !filereadable(bufname(n))',1,1)
endfunction
