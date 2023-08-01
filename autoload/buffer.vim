"Based on BufOnly.vim

function! s:WipeBuffers(bang, predicate)
    let count = s:LoopBuffers(a:bang, a:predicate.
                \' && getbufvar(n, "&buftype") !=# "terminal"')
    let message = ""
	if count.buffer_count == 0
		let message .= "No buffers wiped"
    elseif count.buffer_count == 1
		let message .= "1 buffer wiped"
	elseif count.buffer_count > 1
		let message .= count.buffer_count . " buffers wiped"
	endif
	if count.error_count == 1
		let message .= "; 1 buffer not wiped"
	elseif count.error_count > 1
		let message .= "; " . count.error_count . " buffers not wiped"
	endif
    echom l:message
endfunction

" TODO using getbufinfo, review predicates
function! s:LoopBuffers(bang, predicate)
	let buffer_count = 0
    let error_count = 0
    let ei = &eventignore
    set eventignore+=TabClosed
    for buf in getbufinfo()
        let n = buf.bufnr
        if eval(a:predicate)
            let command = "bwipe" . a:bang . " " . n
            try
                silent exe command
                let buffer_count += 1
            catch
                let error_count += 1
            endtry
        endif
    endfor
    let &eventignore = ei
    return {"buffer_count": buffer_count, "error_count": error_count}
endfunction

function! buffer#BWipe(bang, pattern)
    let s:wipe_pattern = a:pattern
    call s:WipeBuffers(a:bang, 'buflisted(n) && bufname(n) =~# s:wipe_pattern')
endfunction

function! buffer#BWipeFileType(bang, ...)
    if a:0 > 0
        let s:filetype = a:1
    else
        let s:filetype = &ft
    endif
    call s:WipeBuffers(a:bang, 'getbufvar(n, "&ft") == s:filetype')
endfunction

function! buffer#BWipeHidden(bang, pattern)
    if a:pattern == ""
        call s:WipeBuffers(a:bang, 'getbufinfo(n)[0].hidden')
        return
    endif
    let s:wipe_pattern = a:pattern
    call s:WipeBuffers(a:bang, 'getbufinfo(n)[0].hidden && bufname(n) =~# s:wipe_pattern')
endfunction

function! buffer#BWipeNotLoaded()
    call s:WipeBuffers("", 'buflisted(n) && !bufloaded(n)')
endfunction

function! buffer#BWipeUnlisted(bang, pattern)
    if a:pattern == ""
        call s:WipeBuffers(a:bang, '!buflisted(n)')
        return
    endif
    let s:wipe_pattern = a:pattern
    call s:WipeBuffers(a:bang, '!buflisted(n) && bufname(n) =~# s:wipe_pattern')
endfunction

function! buffer#BWipeNotReadable(bang)
    call s:WipeBuffers(a:bang, 'buflisted(n) && !filereadable(bufname(n))')
endfunction
