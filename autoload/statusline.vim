function! statusline#DefaultReadOnlyFlag()
    if !&modifiable
        return '-'
    endif
    if &readonly
        return 'R'
    endif
    return ''
endfunction

function! statusline#DefaultModifiedFlag()
    if ! exists("w:Statusline_modified")
        let w:Statusline_modified = 0
    endif
    if w:Statusline_modified != &modified
        if exists("#StatuslineModifiedUserGroup#User")
            doautocmd <nomodeline> StatuslineModifiedUserGroup User
        endif
        let w:Statusline_modified = &modified
    endif
    if &modified
        return '*'
    endif
    return ''
endfunction

let s:status_line_tail = ' %2*%{&ft}%*'
                     \ . ' %3*%1.(%{statusline#DefaultReadOnlyFlag()}%)%*'
                     \ . ' %4.(%4*%{&fileformat}%*%)'

let s:status_line_tail_column = s:status_line_tail
                     \ . ' :%2.c %4*%L%* %3.P'
                     \ . ' %4*%{&fileencoding}%*'

let s:status_line_tail_line_column = s:status_line_tail
                     \ . ' %l:%2.c %4*%L%* %3.P'
                     \ . ' %4*%{&fileencoding}%*'

function! statusline#GetStatusLineTail()
    if &number
        return s:status_line_tail_column
    endif
    return s:status_line_tail_line_column
endfunction

" b:Statusline_custom_mod_leftline and b:Statusline_custom_mod_rightline are
" joined with %=

function! statusline#DefineModifiedStatusLine()
    if exists("b:Statusline_custom_mod_leftline")
        exec "let &l:statusline='".b:Statusline_custom_mod_leftline."%='"
    else
        let &l:statusline='%<%1*'
            \ . '%{expand("%:t")}'
            \ . '%{statusline#DefaultModifiedFlag()}%*%='
    endif
    if exists("b:Statusline_custom_mod_rightline")
        exec "let &l:statusline='".&l:statusline
                    \.b:Statusline_custom_mod_rightline."'"
        return
    endif
    exec "let &l:statusline='".&l:statusline
                \.statusline#GetStatusLineTail()
                \."'"
endfunction

function! statusline#StatusLineNoFocus()
    return util#truncateFilename(expand("%"),winwidth("%"))
endfunction

function! statusline#DefineStatusLineNoFocus()
    let &l:statusline='%{statusline#StatusLineNoFocus()}'
endfunction

" b:Statusline_custom_leftline and b:Statusline_custom_rightline are
" joined with %=

function! statusline#DefineStatusLine()
    if exists("b:Statusline_custom_leftline")
        exec "let &l:statusline='".b:Statusline_custom_leftline."%='"
    elseif util#isDisposableBuffer()
        let &l:statusline='%<%7*'
            \ . '%{expand("%:t")}'
            \ . '%{statusline#DefaultModifiedFlag()}%*%='
    else
        let &l:statusline='%<'
            \ . '%{expand("%:t")}'
            \ . '%{statusline#DefaultModifiedFlag()}%='
    endif
    if exists("b:Statusline_custom_rightline")
        exec "let &l:statusline='".&l:statusline
                    \.b:Statusline_custom_rightline."'"
        return
    endif
    exec "let &l:statusline='".&l:statusline
                \.statusline#GetStatusLineTail()
                \."'"
endfunction

function! statusline#Highlight(dict)
	for group in keys(a:dict)
        let arguments = a:dict[group]
        if type(arguments) == type({})
            for hikey in keys(arguments)
                exe "hi! ".group." ".s:term.hikey."=".arguments[hikey]
            endfor
        endif
        if type(arguments) == type("")
            exe "hi! ".group." ".s:term."=".arguments
        endif
    endfor
endfunction

function! statusline#HighlightMode(mode)
    exe "call statusline#Highlight({"
        \ . "'StatusLine': {'bg': s:".a:mode."_bg, 'fg': s:".a:mode."_fg},"
        \ . "'User1': {'bg': s:user1_".a:mode."_bg},"
        \ . "'User2': {'bg': s:user2_".a:mode."_bg, 'fg': s:user2_".a:mode."_fg},"
        \ . "'User3': {'bg': s:user3_".a:mode."_bg, 'fg': s:user3_".a:mode."_fg},"
        \ . "'User4': {'bg': s:user4_".a:mode."_bg, 'fg': s:user4_".a:mode."_fg},"
        \ . "'User5': {'bg': s:user5_".a:mode."_bg, 'fg': s:user5_".a:mode."_fg},"
        \ . "'User6': {'bg': s:user6_".a:mode."_bg, 'fg': s:user6_".a:mode."_fg},"
        \ . "'User7': {'bg': s:user7_".a:mode."_bg, 'fg': s:user7_".a:mode."_fg}})"
    exe "call statusline#Highlight({"
        \ . "'StatusLine': s:statusline_".a:mode.","
        \ . "'User1': s:statusline_".a:mode.","
        \ . "'User2': s:statusline_".a:mode.","
        \ . "'User3': s:statusline_".a:mode.","
        \ . "'User4': s:statusline_".a:mode.","
        \ . "'User5': s:statusline_".a:mode.","
        \ . "'User6': s:statusline_".a:mode."})"
endfunction

function! statusline#RedefineStatusLine()
    if &modified
        call statusline#DefineModifiedStatusLine()
    else
        call statusline#DefineStatusLine()
    endif
endfunction

function! statusline#HighlightModifiedStatusLineGroup()
    call statusline#Highlight({
        \ 'User1': {'fg': s:user1_modified_fg}})
endfunction

function! statusline#loadColorTheme(colorTheme)
    let colorMapping = a:colorTheme
    if type(a:colorTheme) == type("")
        exec "let colorMapping = statusline#themes#".a:colorTheme."#getColorMapping()"
    endif
    for mapping in keys(colorMapping)
        let color = statusline#themes#getColor(colorMapping[mapping],s:term)
        exe "let s:".mapping."='".color."'"
    endfor
endfunction

function! statusline#loadTermAttrList(termAttrList)
    for mapping in keys(a:termAttrList)
        exe "let s:".mapping."='".a:termAttrList[mapping]."'"
    endfor
endfunction

function! statusline#getTerm()
    let term='cterm'

    if has('gui_running')
        let term='gui'
    endif

    return term
endfunction

function! statusline#HighlightStatusLineNC()
    call statusline#Highlight({
        \ 'StatusLineNC': {'bg': s:not_current_bg, 'fg': s:not_current_fg}})
    exe "hi! StatusLineNC ".s:term."=".s:statuslinenc
endfunction

function! statusline#LoadTheme(colorTheme)
    if exists("*statusline#themes#".a:colorTheme."#getColorMapping")
        exec "source " . g:vim_dir . "/autoload/statusline/themes/".a:colorTheme.".vim"
    endif

    exec "let colorMapping = statusline#themes#".a:colorTheme."#getColorMapping()"
    exec "let termAttrList = statusline#themes#".a:colorTheme."#getTermAttrList()"

    call statusline#loadColorTheme(colorMapping)
    call statusline#loadTermAttrList(termAttrList)
    call statusline#HighlightMode('normal')
    call statusline#HighlightStatusLineNC()
    call statusline#HighlightModifiedStatusLineGroup()
endfunction

function! statusline#initialize()
    if !exists("g:Statusline_theme")
        let g:Statusline_theme = 'default'
    endif

    call statusline#LoadTheme(g:Statusline_theme)
endfunction

let s:term = statusline#getTerm()
