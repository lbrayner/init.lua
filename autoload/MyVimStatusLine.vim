function! MyVimStatusLine#Highlight(dict)
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

function! MyVimStatusLine#HighlightMode(mode)
    exe "call MyVimStatusLine#Highlight({"
        \ . "'StatusLine': {'bg': s:".a:mode."_bg, 'fg': s:".a:mode."_fg},"
        \ . "'User1': {'bg': s:user1_".a:mode."_bg, 'fg': s:user1_".a:mode."_fg},"
        \ . "'User2': {'bg': s:user2_".a:mode."_bg, 'fg': s:user2_".a:mode."_fg},"
        \ . "'User3': {'bg': s:user3_".a:mode."_bg, 'fg': s:user3_".a:mode."_fg},"
        \ . "'User4': {'bg': s:user4_".a:mode."_bg, 'fg': s:user4_".a:mode."_fg},"
        \ . "'User5': {'bg': s:user5_".a:mode."_bg, 'fg': s:user5_".a:mode."_fg}})"
    exe "call MyVimStatusLine#Highlight({"
        \ . "'StatusLine': s:statusline_".a:mode.","
        \ . "'User1': s:statusline_".a:mode.","
        \ . "'User2': s:statusline_".a:mode.","
        \ . "'User3': s:statusline_".a:mode.","
        \ . "'User4': s:statusline_".a:mode.","
        \ . "'User5': s:statusline_".a:mode."})"
endfunction

function! MyVimStatusLine#loadColorTheme(colorTheme)
    let colorMapping = a:colorTheme
    if type(a:colorTheme) == type("")
        exec "let colorMapping = MyVimStatusLine#themes#".a:colorTheme."#getColorMapping()"
    endif
    for mapping in keys(colorMapping)
        let color = MyVimStatusLine#themes#getColor(colorMapping[mapping],s:term)
        exe "let s:".mapping."='".color."'"
    endfor
endfunction

function! MyVimStatusLine#loadTermAttrList(termAttrList)
    for mapping in keys(a:termAttrList)
        exe "let s:".mapping."='".a:termAttrList[mapping]."'"
    endfor
endfunction

function! MyVimStatusLine#getTerm()
    let term='cterm'

    if has('gui_running')
        let term='gui'
    endif

    return term
endfunction

function! MyVimStatusLine#HighlightStatusLineNC()
    call MyVimStatusLine#Highlight({
        \ 'StatusLineNC': {'bg': s:not_current_bg, 'fg': s:not_current_fg}})
    exe "hi! StatusLineNC ".s:term."=".s:statuslinenc
endfunction

function! MyVimStatusLine#LoadTheme(colorTheme)
    if exists("*MyVimStatusLine#themes#".a:colorTheme."#getColorMapping")
        exec "source autoload/MyVimStatusLine/themes/".a:colorTheme.".vim"
    endif

    exec "let colorMapping = MyVimStatusLine#themes#".a:colorTheme."#getColorMapping()"
    exec "let termAttrList = MyVimStatusLine#themes#".a:colorTheme."#getTermAttrList()"

    call MyVimStatusLine#loadColorTheme(colorMapping)
    call MyVimStatusLine#loadTermAttrList(termAttrList)
    call MyVimStatusLine#HighlightMode('normal')
    call MyVimStatusLine#HighlightStatusLineNC()
endfunction

function! MyVimStatusLine#initialize()
    if !exists("g:MyVimStatusLine_theme")
        let g:MyVimStatusLine_theme = 'default'
    endif

    call MyVimStatusLine#LoadTheme(g:MyVimStatusLine_theme)
endfunction

let s:term = MyVimStatusLine#getTerm()
