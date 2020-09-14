function! s:TabLeave()
    let g:tab#tabLeaveTriggered = 1
    if exists("g:tab#lastTab")
        let g:tab#beforeLastTab = g:tab#lastTab
    endif
    let g:tab#lastTab = tabpagenr()
endfunction

function! s:TabClosed()
    if exists("g:tab#tabLeaveTriggered") && g:tab#tabLeaveTriggered
        if exists("g:tab#beforeLastTab")
            let g:tab#lastTab = g:tab#beforeLastTab
            unlet g:tab#beforeLastTab
        endif
    endif
    if exists("g:tab#lastTab")
        if !util#TabExists(g:tab#lastTab)
                    \|| g:tab#lastTab < gettabvar(g:tab#lastTab,'tab_tabnr')
            let g:tab#lastTab = g:tab#lastTab - 1
        endif
    endif
    if exists("g:tab#tabLeaveTriggered") && g:tab#tabLeaveTriggered
        let g:tab#tabLeaveTriggered = 0
        if util#TabExists(g:tab#lastTab)
            call tab#GoToLastTab()
        endif
    endif
endfunction

augroup LastTabAutoGroup
    autocmd!
    autocmd TabEnter * let t:tab_tabnr = tabpagenr()
                \| let g:tab#tabLeaveTriggered = 0
    autocmd TabLeave * call s:TabLeave()
    autocmd TabClosed * call s:TabClosed()
augroup END

function! s:DoTabEqualizeWindows()
    call tab#TabDo("res 1000 | normal! \<c-w>=")
endfunction

command! TabEqualizeWindows call s:DoTabEqualizeWindows()
command! -bang TabCloseRight call tab#TabCloseRight('<bang>')
command! -bang TabCloseLeft call tab#TabCloseLeft('<bang>')
command! Tabnew call util#PreserveViewPort("tabe ".fnameescape(expand("%")))
command! Tabedit Tabnew

augroup TabActionsOnVimEnter
    autocmd!
    autocmd VimEnter * call s:DoTabEqualizeWindows()
augroup END

map <Plug>GoToTab :call tab#GoToTab()<cr>
