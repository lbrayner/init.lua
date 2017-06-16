function! s:MessageBuffers(buffer_count)
	if a:buffer_count == 1
		echomsg a:buffer_count "buffer wiped"
	elseif a:buffer_count > 1
		echomsg a:buffer_count "buffers wiped"
	endif
endfunction

function! s:LoopBuffers(predicate)
	let last_buffer = bufnr('$')
	let delete_count = 0
	let n = 1
	while n <= last_buffer
        let test_var = eval('buflisted(n) && ' . a:predicate)
        if test_var
            if getbufvar(n, '&modified')
                echohl ErrorMsg
                echomsg 'No write since last change for buffer' n '(add ! to override)'
                echohl None
            else
                silent exe 'bwipe ' . n
				if ! buflisted(n)
					let delete_count = delete_count+1
				endif
            endif
        endif
		let n = n+1
	endwhile
    call s:MessageBuffers(delete_count)
endfunction

function! s:BufWipeTabFunction()
    let tab_list = tabpagebuflist()
    let s:tab_dic = {}
    for i in tab_list
        exec 'let s:tab_dic.' . i . ' = ' . i
    endfor
    call s:LoopBuffers('has_key(s:tab_dic,n)')
endfunction


command! BufWipeTab call s:BufWipeTabFunction() | silent exec ":tabp"
