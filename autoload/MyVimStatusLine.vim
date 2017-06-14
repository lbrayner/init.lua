function! MyVimStatusLine#Highlight(dict)
	for group in keys(a:dict)
        let arguments = a:dict[group]
        if type(arguments) == type({})
            for hikey in keys(arguments)
                exe "hi! ".group." ".s:status_vmode.hikey."=".arguments[hikey]
            endfor
        endif
        if type(arguments) == type("")
            exe "hi! ".group." ".s:status_vmode."=".arguments
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

function! MyVimStatusLine#loadColorMappings(colorMapping)
    for mapping in keys(a:colorMapping)
        let color = MyVimStatusLine#themes#getColor(a:colorMapping[mapping],s:status_vmode)
        exe "let s:".mapping."='".color."'"
    endfor
endfunction

function! MyVimStatusLine#getVMode()
    let status_vmode='cterm'

    if has('gui_running')
        let status_vmode='gui'
    endif

    return status_vmode
endfunction

function! MyVimStatusLine#HighlightStatusLineNC()
    call MyVimStatusLine#Highlight({
        \ 'StatusLineNC': {'bg': s:not_current_bg, 'fg': s:not_current_fg}})
    exe "hi! StatusLineNC ".s:status_vmode."=".s:statuslinenc
endfunction

function! s:LoadTheme()
    exec "let colorMapping = MyVimStatusLine#themes#".g:MyVimStatusLine_theme."#getColorMapping()"
    call MyVimStatusLine#loadColorMappings(colorMapping)
endfunction

function! MyVimStatusLine#initialize()
    if !exists("g:MyVimStatusLine_theme")
        let g:MyVimStatusLine_theme = 'default'
    endif

    " call MyVimStatusLine#loadColorMappings(s:colorMapping)
    call s:LoadTheme()
endfunction

let s:status_vmode = MyVimStatusLine#getVMode()
let s:statuslinenc='NONE'

let s:statusline_normal='NONE'
let s:statusline_insert='bold'
