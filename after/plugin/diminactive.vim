function! s:DimInactiveExceptions()
    if exists("b:dim_inactive") && b:dim_inactive
        return
    endif
    if util#WindowIsFloating()
        return
    endif
    if !empty(&buftype)
        set winhighlight+=NormalNC:NONE
        let b:dim_inactive = 1
    endif
endfunction

function! s:DimInactiveWinLeave()
    if exists("b:dim_inactive") && b:dim_inactive
        return
    endif
    if &diff || &previewwindow
        set winhighlight+=NormalNC:NONE
        return
    endif
    set winhighlight-=NormalNC:NONE
endfunction

" https://gist.github.com/ctaylo21/c3620a945cee6fc3eb3cb0d7f57faf00
" Background colors for inactive windows
function! s:HighlightNormalNC()
    execute "highlight NormalNC ctermbg=".
                \statusline#themes#getColor("x236_Grey19","cterm").
                \" guibg=".statusline#themes#getColor("x236_Grey19","gui")
endfunction

function! s:DimInactiveEnable()
    augroup DimInactive
      autocmd!
      autocmd BufWinEnter,TermOpen * call s:DimInactiveExceptions()
      autocmd VimEnter * autocmd DimInactive
                  \ WinLeave * call s:DimInactiveWinLeave()
        autocmd ColorScheme * call s:HighlightNormalNC()
        autocmd User DimInactive call s:DimInactiveExceptions()
    augroup END
    call s:HighlightNormalNC()
    if v:vim_did_enter
        doautocmd DimInactive VimEnter
    endif
endfunction

function! s:DimInactiveDisable()
    augroup DimInactive
      autocmd!
    augroup END
    highlight clear NormalNC
endfunction

call s:DimInactiveEnable()

command! -nargs=0 HighlightNormalNC call s:HighlightNormalNC()
command! -nargs=0 DimInactiveEnable call s:DimInactiveEnable()
command! -nargs=0 DimInactiveDisable call s:DimInactiveDisable()
