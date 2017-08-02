"Based on BufOnly.vim

function! s:MessageBuffers(buffer_count)
	if a:buffer_count == 1
		echomsg a:buffer_count "buffer wiped"
	elseif a:buffer_count > 1
		echomsg a:buffer_count "buffers wiped"
	endif
endfunction

function! s:LoopBuffers(test_buflisted,predicate)
	let last_buffer = bufnr('$')
	let delete_count = 0
	let n = 1
    if a:test_buflisted
        let buflisted_pred = 'buflisted(n) && '
    else
        let buflisted_pred = ''
    endif
	while n <= last_buffer
        let test_var = eval(buflisted_pred . a:predicate)
        if test_var
            if getbufvar(n, '&modified')
                echoe 'No write since last change for buffer' n '(add ! to override)'
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

function! MyVimGoodies#BufferGoodies#BufWipeTab()
    let tab_list = tabpagebuflist()
    let s:tab_dic = {}
    for i in tab_list
        exec 'let s:tab_dic.' . i . ' = ' . i
    endfor
    call s:LoopBuffers(1,'has_key(s:tab_dic,n)')
endfunction

let s:wipe_pattern = ''
let s:filetype = ''

function! MyVimGoodies#BufferGoodies#BufWipeFileType(...)
    if a:0 > 0
        let s:filetype = a:1
    else
        let s:filetype = &ft
    endif
    call s:LoopBuffers(0,'getbufvar(n,"&ft") == s:filetype')
endfunction

function! MyVimGoodies#BufferGoodies#BufWipe(...)
    if a:0 > 0
        let s:wipe_pattern = a:1
    else
        let s:wipe_pattern = expand('%:t')
    endif
    call s:LoopBuffers(1,'bufname(n) =~? s:wipe_pattern')
endfunction

function! MyVimGoodies#BufferGoodies#BufWipeHidden(...)
    if a:0 > 0
        let s:wipe_pattern = a:1
    else
        let s:wipe_pattern = expand('%:t')
    endif
    call s:LoopBuffers(0,'bufname(n) =~? s:wipe_pattern')
endfunction

function! MyVimGoodies#BufferGoodies#BufWipeNotLoaded()
    call s:LoopBuffers(1,'!bufloaded(n)')
endfunction

let s:tab_dic = {}

function! MyVimGoodies#BufferGoodies#BufWipeTabOnly()
    let tab_list = tabpagebuflist()
    let s:tab_dic = {}
    for i in tab_list
        exec 'let s:tab_dic.' . i . ' = ' . i
    endfor
    call s:LoopBuffers(1,'!has_key(s:tab_dic,n)')
endfunction
