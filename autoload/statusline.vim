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
        if exists("#Statusline#User#CustomStatusline")
            doautocmd <nomodeline> User CustomStatusline
        endif
        let w:Statusline_modified = &modified
    endif
    if &modified
        return '*'
    endif
    return ''
endfunction

function! s:GetLineFormat()
    return '%' . len(line("$")) . 'l'
endfunction

let s:status_line_tail_column = ' :%-3.c %3.P %L'
                     \ . ' %4*%{&fileencoding}%*'
                     \ . ' %4.(%4*%{&fileformat}%*%)'
                     \ . ' %2*%{&filetype}%* '

function! s:StatusLineTailLineColumn()
    return ' ' . s:GetLineFormat() . ':%-3.c %3.P %L'
                \ . ' %4*%{&fileencoding}%*'
                \ . ' %4.(%4*%{&fileformat}%*%)'
                \ . ' %2*%{&filetype}%* '
endfunction

function! statusline#GetStatusLineTail()
    if &number
        return s:status_line_tail_column
    endif
    return s:StatusLineTailLineColumn()
endfunction

" b:Statusline_custom_mod_leftline and b:Statusline_custom_mod_rightline are
" joined with %=

" margins of 1 column (on both sides)
function! statusline#DefineModifiedStatusLine()
    let filename=substitute(expand("%:t"),"'","''","g")
    if exists("b:Statusline_custom_mod_leftline")
        exec "let &l:statusline=' ".b:Statusline_custom_mod_leftline."'"
    elseif &previewwindow
        let &l:statusline=' %<%1*'
                    \ . '['.filename
                    \ . '%{statusline#DefaultModifiedFlag()}]%*'
    else
        let &l:statusline=' %<%1*'
                    \ . filename
                    \ . '%{statusline#DefaultModifiedFlag()}%*'
    endif
    if exists("b:Statusline_custom_mod_rightline")
        exec "let &l:statusline='".&l:statusline
                    \ . '%='
                    \ . b:Statusline_custom_mod_rightline." '"
        return
    endif
    let &l:statusline.=' %3*%1.(%{statusline#DefaultReadOnlyFlag()}%)%*'
    exec "let &l:statusline='".&l:statusline
                \ . '%='
                \ . statusline#GetStatusLineTail()
                \ . "'"
endfunction

" margins of 1 column (on both sides)
function! statusline#DefineStatusLineNoFocus()
    let filename=substitute(expand("%"),"'","''","g")
    let isnumbersonly=filename =~# '^[0-9]\+$'
    if isnumbersonly
        let &l:statusline=' '.filename.' '
        return
    endif
    if &previewwindow
        if expand("%") == ""
            let &l:statusline=' [Preview] '
            return
        endif
        let &l:statusline=' [%{util#truncateFilename(expand("%"),winwidth("%")-4)}] '
    else
        let &l:statusline=' %{util#truncateFilename(expand("%"),winwidth("%")-2)} '
    endif
endfunction

" b:Statusline_custom_leftline and b:Statusline_custom_rightline are
" joined with %=

" margins of 1 column (on both sides)
function! statusline#DefineStatusLine()
    let filename=substitute(expand("%:t"),"'","''","g")
    if exists("b:Statusline_custom_leftline")
        exec "let &l:statusline=' ".b:Statusline_custom_leftline."'"
    elseif &previewwindow
        if expand("%") == ""
            let &l:statusline=' %<'
                \ . '[Preview]'
        else
            let &l:statusline=' %<'
                \ . '['.filename
                \ . '%{statusline#DefaultModifiedFlag()}]'
        endif
    elseif &buftype == "nofile"
        let &l:statusline=' %<%7*'
            \ . filename
            \ . '%{statusline#DefaultModifiedFlag()}%*'
    else
        let &l:statusline=' %<'
            \ . filename
            \ . '%{statusline#DefaultModifiedFlag()}'
    endif
    if exists("b:Statusline_custom_rightline")
        exec "let &l:statusline='".&l:statusline
                    \ . '%='
                    \ . b:Statusline_custom_rightline." '"
        return
    endif
    " An extra space where the modified flag would be
    let &l:statusline.=' '
    let &l:statusline.=' %3*%1.(%{statusline#DefaultReadOnlyFlag()}%)%*'
    exec "let &l:statusline='".&l:statusline
                \ . '%='
                \ . statusline#GetStatusLineTail()
                \ . "'"
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

function! statusline#HighlightPreviousMode()
    if exists("g:statusline#previousMode")
        call statusline#HighlightMode(g:statusline#previousMode)
    endif
endfunction

function! statusline#HighlightMode(mode)
    if exists("g:statusline#mode")
        let g:statusline#previousMode = g:statusline#mode
    endif
    let g:statusline#mode = a:mode
    exe "call statusline#Highlight({"
        \ . "'StatusLine': {'bg': s:".a:mode."_bg, 'fg': s:".a:mode."_fg},"
        \ . "'User1': {'bg': s:user1_".a:mode."_bg, 'fg': s:user1_".a:mode."_fg},"
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
        \ . "'User6': s:statusline_".a:mode.","
        \ . "'User7': s:statusline_".a:mode."})"
endfunction

function! statusline#RedefineStatusLine()
    if &modified
        call statusline#DefineModifiedStatusLine()
    else
        call statusline#DefineStatusLine()
    endif
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
    if has('gui_running') || &termguicolors
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
endfunction

function! statusline#initialize()
    if !exists("g:Statusline_theme")
        let g:Statusline_theme = 'default'
    endif

    call statusline#LoadTheme(g:Statusline_theme)
endfunction

let s:term = statusline#getTerm()
