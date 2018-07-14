function! statusline#statusline#DefaultReadOnlyFlag()
    if !&modifiable
        return '-'
    endif
    if &readonly
        return 'R'
    endif
    return ''
endfunction

function! statusline#statusline#DefaultModifiedFlag()
    if ! exists("w:MVSL_modified")
        let w:MVSL_modified = 0
    endif
    if w:MVSL_modified != &modified
        if exists("#StatuslineModifiedUserGroup#User")
            doautocmd <nomodeline> StatuslineModifiedUserGroup User
        endif
        let w:MVSL_modified = &modified
    endif
    if &modified
        return '*'
    endif
    return ''
endfunction

let s:status_line_tail = ' %2*%{&ft}%*'
                     \ . ' %3*%1.(%{statusline#statusline#DefaultReadOnlyFlag()}%)%*'
                     \ . ' %4.(%4*%{&fileformat}%*%)'

let s:status_line_tail_column = s:status_line_tail
                     \ . ' :%2.c %4*%L%* %3.P'
                     \ . ' %4*%{&fileencoding}%*'

let s:status_line_tail_line_column = s:status_line_tail
                     \ . ' %l:%2.c %4*%L%* %3.P'
                     \ . ' %4*%{&fileencoding}%*'

function! statusline#statusline#GetStatusLineTail()
    if &number
        return s:status_line_tail_column
    endif
    return s:status_line_tail_line_column
endfunction

function! statusline#statusline#DefineModifiedStatusLine()
    if exists("b:MVSL_custom_mod_leftline")
        exec "let &l:statusline='".b:MVSL_custom_mod_leftline."'"
    else
        let &l:statusline='%<%1*'
            \ . '%{expand("%:t")}'
            \ . '%{statusline#statusline#DefaultModifiedFlag()}%*%='
    endif
    exec "let &l:statusline='".&l:statusline
                \.statusline#statusline#GetStatusLineTail()
                \."'"
endfunction

function! statusline#statusline#StatusLineNoFocus()
    let filename=expand("%")
    if len(filename) <= winwidth("%")
        return filename
    endif
    let trunc_fname_head=strpart(expand("%:h"),0,winwidth("%")-len(expand("%:t"))-1-3)
    return trunc_fname_head.".../".expand("%:t")
endfunction

function! statusline#statusline#DefineStatusLineNoFocus()
    let &l:statusline='%{statusline#statusline#StatusLineNoFocus()}'
endfunction

function! statusline#statusline#DefineStatusLine()
    if exists("b:MVSL_custom_leftline")
        exec "let &l:statusline='".b:MVSL_custom_leftline."'"
    else
        let &l:statusline='%<'
            \ . '%{expand("%:t")}'
            \ . '%{statusline#statusline#DefaultModifiedFlag()}%='
    endif
    exec "let &l:statusline='".&l:statusline
                \.statusline#statusline#GetStatusLineTail()
                \."'"
endfunction
