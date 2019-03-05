"Based on BufOnly.vim

function! s:MessageBuffers(buffer_count)
	if a:buffer_count == 1
		echomsg a:buffer_count "buffer wiped"
	elseif a:buffer_count > 1
		echomsg a:buffer_count "buffers wiped"
	endif
endfunction

function! s:WipeBuffers(predicate)
    let buffer_count = s:LoopBuffers(a:predicate,'bwipe')
    call s:MessageBuffers(buffer_count)
endfunction

function! s:LoopBuffers(predicate,command)
	let last_buffer = bufnr('$')
	let buffer_count = 0
	let n = 1
	while n <= last_buffer
        if eval(a:predicate)
            silent exe a:command . ' ' . n
            let buffer_count = buffer_count+1
        endif
		let n = n+1
	endwhile
    return buffer_count
endfunction

function! buffer#BufWipeTab()
    let tab_list = tabpagebuflist()
    let s:tab_dic = {}
    for i in tab_list
        exec 'let s:tab_dic.' . i . ' = ' . i
    endfor
    call s:WipeBuffers('buflisted(n) && has_key(s:tab_dic,n)')
endfunction

let s:wipe_pattern = ''
let s:filetype = ''

function! buffer#BufWipeFileType(...)
    if a:0 > 0
        let s:filetype = a:1
    else
        let s:filetype = &ft
    endif
    call s:WipeBuffers(0,'getbufvar(n,"&ft") == s:filetype')
endfunction

function! buffer#BufWipe(...)
    if a:0 > 0
        let s:wipe_pattern = a:1
    else
        let s:wipe_pattern = expand('%:t')
    endif
    call s:WipeBuffers('buflisted(n) && bufname(n) =~? s:wipe_pattern')
endfunction

function! buffer#BufWipeHidden(...)
    if a:0 > 0
        let s:wipe_pattern = a:1
    else
        let s:wipe_pattern = expand('%:t')
    endif
    call s:WipeBuffers(0,'bufname(n) =~? s:wipe_pattern')
endfunction

function! buffer#BufWipeNotLoaded()
    call s:WipeBuffers('buflisted(n) && !bufloaded(n)')
endfunction

let s:tab_dic = {}

function! buffer#BufWipeTabOnly()
    let tab_list = tabpagebuflist()
    let s:tab_dic = {}
    for i in tab_list
        exec 'let s:tab_dic.' . i . ' = ' . i
    endfor
    call s:WipeBuffers('buflisted(n) && !has_key(s:tab_dic,n)')
endfunction

function! buffer#BufWipeForce(...)
    if a:0 > 0
        let s:wipe_pattern = a:1
    else
        let s:wipe_pattern = expand('%:t')
    endif
    let buffer_count = s:LoopBuffers('buflisted(n) && bufname(n) =~?'
                                    \ . ' s:wipe_pattern','bwipe!')
    call s:MessageBuffers(buffer_count)
endfunction

function! buffer#BufWipeForceUnlisted(...)
    if a:0 > 0
        let s:wipe_pattern = a:1
    else
        let s:wipe_pattern = expand('%:t')
    endif
    let buffer_count =  s:LoopBuffers('!buflisted(n) && bufname(n) =~?'
                                    \ . ' s:wipe_pattern','bwipe!')
    call s:MessageBuffers(buffer_count)
endfunction
