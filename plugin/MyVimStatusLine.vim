set statusline=%<%f%=\ %1*%y%*
set statusline+=\ %4.(#%n%)
set statusline+=\ %2*%2.(%R%)\ %3.(%m%)%*
set statusline+=\ %4.(%3*%{&fileformat}%*%)
set statusline+=\ %4.l:%4.(%c%V%)\ %4*%L%*\ %3.P
set statusline+=\ %5*%{&fileencoding}%*

call initializer#initialize()

function! s:Highlight(dict)
	for group in keys(a:dict)
        let arguments = a:dict[group]
        if type(arguments) == type({})
            for hikey in keys(arguments)
                exe "hi! ".group." ".g:status_vmode.hikey."=".arguments[hikey]
            endfor
        endif
        if type(arguments) == type("")
            exe "hi! ".group." ".g:status_vmode."=".arguments
        endif
    endfor
endfunction

function! s:HighlightMode(mode)
    exe "call s:Highlight({"
        \ . "'StatusLine': {'bg': g:".a:mode."_bg, 'fg': g:".a:mode."_fg},"
        \ . "'User1': {'bg': g:user1_".a:mode."_bg, 'fg': g:user1_".a:mode."_fg},"
        \ . "'User2': {'bg': g:user2_".a:mode."_bg, 'fg': g:user2_".a:mode."_fg},"
        \ . "'User3': {'bg': g:user3_".a:mode."_bg, 'fg': g:user3_".a:mode."_fg},"
        \ . "'User4': {'bg': g:user4_".a:mode."_bg, 'fg': g:user4_".a:mode."_fg},"
        \ . "'User5': {'bg': g:user5_".a:mode."_bg, 'fg': g:user5_".a:mode."_fg}})"
    exe "call s:Highlight({"
        \ . "'StatusLine': g:statusline_".a:mode.","
        \ . "'User1': g:statusline_".a:mode.","
        \ . "'User2': g:statusline_".a:mode.","
        \ . "'User3': g:statusline_".a:mode.","
        \ . "'User4': g:statusline_".a:mode.","
        \ . "'User5': g:statusline_".a:mode."})"
endfunction

augroup MyVimStatusLineInsertEnterLeave
    autocmd! InsertEnter * call s:HighlightMode('insert')
    autocmd! InsertLeave * call s:HighlightMode('normal')
augroup END

exe "hi! StatusLineNC ".g:status_vmode."=".g:statuslinenc

call s:HighlightMode('normal')

call s:Highlight({
    \ 'StatusLineNC': {'bg': g:not_current_bg, 'fg': g:not_current_fg}})
