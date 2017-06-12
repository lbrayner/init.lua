set statusline=%<%f%=\ %y
set statusline+=\ %4.(#%n%)
set statusline+=\ %1*%2.(%R%)\ %3.(%m%)%*
set statusline+=\ %4.(%2*%{&fileformat}%*%)
set statusline+=\ %4.l:%4.(%c%V%)\ %3*%L%*\ %3.P
set statusline+=\ %{&fileencoding}

let s:vmode='cterm'

if has('gui_running')
    let s:vmode='gui'
endif

let s:normal_bg='#5f87ff'
let s:normal_fg='#121212'

let s:insert_bg='#121212'
let s:insert_fg='#00ff87'

let s:user1_normal_bg='#121212'
let s:user1_normal_fg='#d7005f'

let s:user1_insert_bg=s:insert_fg
let s:user1_insert_fg='Purple'

let s:user2_normal_bg='#121212'
let s:user2_normal_fg='DarkGray'

let s:user2_insert_bg=s:insert_fg
let s:user2_insert_fg='Orange'

let s:user3_normal_bg='#121212'
let s:user3_normal_fg='DarkGray'

let s:user3_insert_bg=s:insert_fg
let s:user3_insert_fg='Orange'

let s:not_current_bg='DarkGray'
let s:not_current_fg='#121212'

function! s:Highlight(dict)
	for group in keys(a:dict)
        let arguments = a:dict[group]
        for hikey in keys(arguments)
            exe "hi! ".group." ".s:vmode.hikey."=".arguments[hikey]
        endfor
    endfor
endfunction

function! s:HighlightInsert()
    call s:Highlight({
        \ 'StatusLine': {'bg': s:insert_bg, 'fg': s:insert_fg},
        \ 'User1': {'bg': s:user1_insert_bg, 'fg': s:user1_insert_fg},
        \ 'User2': {'bg': s:user2_insert_bg, 'fg': s:user2_insert_fg},
        \ 'User3': {'bg': s:user3_insert_bg, 'fg': s:user3_insert_fg}})
endfunction

function! s:HighlightNormal()
    call s:Highlight({
        \ 'StatusLine': {'bg': s:normal_bg, 'fg': s:normal_fg},
        \ 'User1': {'bg': s:user1_normal_bg, 'fg': s:user1_normal_fg},
        \ 'User2': {'bg': s:user2_normal_bg, 'fg': s:user2_normal_fg},
        \ 'User3': {'bg': s:user3_normal_bg, 'fg': s:user3_normal_fg}})
endfunction

augroup MyVimStatusLineInsertEnterLeave
    autocmd! InsertEnter * call s:HighlightInsert()
    autocmd! InsertLeave * call s:HighlightNormal()
augroup END

call s:HighlightNormal()

call s:Highlight({
    \ 'StatusLineNC': {'bg': s:not_current_bg, 'fg': s:not_current_fg}})
