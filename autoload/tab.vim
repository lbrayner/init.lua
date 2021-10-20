" http://vim.wikia.com/wiki/Run_a_command_in_multiple_buffers
function! tab#TabDo(command)
  let currentTab=tabpagenr()
  execute 'tabdo ' . a:command
  execute 'tabn ' . currentTab
endfunction

function! s:PrintTabs(currentTab)
    let l:currentTab=tabpagenr()
    if l:currentTab == a:currentTab
        echohl WarningMsg
    else
        echohl Directory
    endif
    let spacing = "  "
    echo spacing . l:currentTab " " . fnamemodify(getcwd(),":~")
    echohl None
    let currentWindow=winnr()
    for window in gettabinfo(l:currentTab)[0]["windows"]
        if win_id2win(window) == currentWindow
            let spacing = "> "
        else
            let spacing = "  "
        endif
        let buf_nr = getwininfo(window)[0]["bufnr"]
        let buf_name = bufname(buf_nr)
        let noname = buf_name == ""
        let is_help = getbufvar(buf_nr,"&buftype") == "help"
        let loclist = getwininfo(window)[0]["loclist"]
        let quickfix = getwininfo(window)[0]["quickfix"]
        let is_tagbar = getbufvar(buf_nr,"&filetype") == "tagbar"
        let is_dirvish = getbufvar(buf_nr,"&filetype") == "dirvish"
        let prefix = "\t" . spacing
        if loclist
            echo prefix . "[Location List]"
        elseif quickfix
            echo prefix . "[Quickfix List]"
        elseif is_help
            echo prefix . "[help] " . fnamemodify(buf_name,":t")
        elseif noname
            echo prefix . "[No Name]"
        elseif is_tagbar
            echo prefix . "[Tagbar]"
        elseif is_dirvish
            echo prefix . "[Dirvish]"
        else
            echo prefix . fnamemodify(buf_name,":~:.")
        endif
    endfor
endfunction

function! tab#GoToTab()
    let s:a_tab_nr=tabpagenr()
    echo "Current tabs:"
    " https://github.com/chrisbra/SaveSigns.vim
    " consider saving and restoring the signs
    sign unplace *
    noautocmd call tab#TabDo("call s:PrintTabs(s:a_tab_nr)")
    let tab = input("Go to tab (" . tabpagenr() . "): ")
    let tab = substitute(tab,"[^0-9]","","g")
    if tab == ""
        return
    endif
    exe "tabn " . tab
endfunction

function! tab#GoToLastTab()
    if !exists("g:tab#lastTab")
        let g:tab#lastTab = tabpagenr()
        let g:tab#beforeLastTab = tabpagenr()
    endif
    if len(gettabinfo(g:tab#lastTab)) > 0
        exe "tabn " . g:tab#lastTab
    else
        echom "Tab " . g:tab#lastTab . " doesn't exist."
    endif
endfunction

" https://superuser.com/a/555047
function! tab#TabCloseRight(bang)
    let currrentTab = tabpagenr()
    while currrentTab < tabpagenr('$')
        noautocmd exe 'tabclose' . a:bang . ' ' . (currrentTab + 1)
    endwhile
endfunction

function! tab#TabCloseLeft(bang)
    while tabpagenr() > 1
        noautocmd exe 'tabclose' . a:bang . ' 1'
    endwhile
endfunction
