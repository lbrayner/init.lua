"Based on BufOnly.vim

function! s:MessageBuffers(buffer_count)
	if a:buffer_count == 1
		echomsg a:buffer_count "buffer wiped"
	elseif a:buffer_count > 1
		echomsg a:buffer_count "buffers wiped"
	endif
endfunction

function! s:WipeBuffers(predicate)
    let buffer_count = s:LoopBuffers(a:predicate.
                \" && getbufvar(n,'&buftype') !=# 'terminal'",
                \'bwipe')
    call s:MessageBuffers(buffer_count)
endfunction

function! s:LoopBuffers(predicate,command,...)
	let last_buffer = bufnr('$')
	let buffer_count = 0
	let n = 1
	while n <= last_buffer
        if eval(a:predicate)
            let command = a:command . " " . n
            if a:0 > 0 && a:1
                " Ignore errors
                silent! exe command
            else
                silent exe command
            endif
            let buffer_count = buffer_count+1
        endif
		let n = n+1
	endwhile
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
    let s:wipe_pattern = a:pattern
    call s:WipeBuffers('bufname(n) =~# s:wipe_pattern && getbufinfo(n)[0].hidden')
endfunction

function! buffer#BWipeNotLoaded()
    call s:WipeBuffers('buflisted(n) && !bufloaded(n)')
endfunction

function! buffer#BWipeForce(pattern)
    let s:wipe_pattern = a:pattern
    call s:LoopBuffers('buflisted(n) && bufname(n) =~#'
                \ . ' s:wipe_pattern','bwipe!', 1)
endfunction

function! buffer#BWipeForceUnlisted(pattern)
    let s:wipe_pattern = a:pattern
    call s:LoopBuffers('!buflisted(n) && bufname(n) =~#'
                \ . ' s:wipe_pattern','bwipe!', 1)
endfunction

function! buffer#BWipeNotReadable()
    call s:WipeBuffers('buflisted(n) && !filereadable(bufname(n))')
endfunction

function! buffer#BWipeNotReadableForce()
    call s:LoopBuffers('buflisted(n) && !filereadable(bufname(n))', "bwipe!", 1)
endfunction
