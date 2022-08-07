" http://vim.wikia.com/wiki/Run_a_command_in_multiple_buffers
" Tweaked by me to preserve last accessed tab
function! tab#TabDo(command)
    let current_tab=tabpagenr()
    exe "normal! g\<Tab>"
    let previous_tab=tabpagenr()
    try
        execute "tabdo " . a:command
    finally
        execute "tabn " . previous_tab
        execute "tabn " . current_tab
    endtry
endfunction

function! s:PrintWindows(current_tab, number_of_tabs)
    let l:current_tab=tabpagenr()
    if l:current_tab == a:current_tab
        echohl WarningMsg
    else
        echohl Directory
    endif
    echo " ".printf(printf("%%%dd", len(a:number_of_tabs)), l:current_tab)
                \ " ".fnamemodify(getcwd(),":~")
    echohl None
    let currentWindow=winnr()
    for window in gettabinfo(l:current_tab)[0]["windows"]
        let winnr = win_id2win(window)
        if winnr == currentWindow
            let spacing = ">"
        else
            let spacing = " "
        endif
        let wininfo = getwininfo(window)
        let buf_nr = wininfo[0]["bufnr"]
        let buf_name = bufname(buf_nr)
        let noname = buf_name == ""
        let is_help = getbufvar(buf_nr,"&buftype") == "help"
        let loclist = wininfo[0]["loclist"]
        let quickfix = wininfo[0]["quickfix"]
        let is_dirvish = getbufvar(buf_nr,"&filetype") == "dirvish"
        let prefix = "\t" . spacing
        let preview = ""
        if getwinvar(winnr,"&previewwindow")
            let preview = "Previewing: "
        endif
        if loclist
            echo prefix "[Location List]"
        elseif quickfix
            echo prefix "[Quickfix List] ".getqflist({"title": 1}).title
        elseif is_help
            echo prefix "[help]" fnamemodify(buf_name,":t")
        elseif noname
            echo prefix "[No Name]"
        elseif is_dirvish
            echo prefix "[Dirvish]"
        " Fugitive summary
        elseif getbufvar(buf_nr,"fugitive_type") ==# "index"
            if util#IsInDirectory(getcwd(), FugitiveGitDir())
                echo prefix preview."Fugitive summary"
            else
                let dir = substitute(util#NPath(FugitiveGitDir()),'/\.git$',"","")
                echo prefix preview."Fugitive summary" "@" dir
            endif
        " Fugitive temporary buffers
        elseif exists("*FugitiveResult") && len(FugitiveResult(buf_nr))
            let fcwd = FugitiveResult(buf_nr).cwd
            let command = "Git ".join(FugitiveResult(buf_nr).args," ")
            if getwinvar(winnr,"&previewwindow")
                let preview = "Previewing "
            endif
            if util#IsInDirectory(getcwd(), fcwd)
                echo prefix preview."Fugitive:" command
            else
                echo prefix preview."Fugitive:" command "@" util#NPath(fcwd)
            endif
        " Fugitive objects
        elseif exists("*FugitiveParse") && stridx(buf_name,"fugitive://") == 0
            let [rev, dir] = FugitiveParse(buf_name)
            let dir = substitute(dir,'/\.git$',"","")
            if util#IsInDirectory(getcwd(), dir)
                echo prefix rev
            else
                echo prefix util#NPath(dir) rev
            endif
        else
            echo prefix preview.fnamemodify(buf_name,":~:.")
        endif
    endfor
endfunction

function! tab#GoToTab()
    let s:a_tab_nr=tabpagenr()
    echo "Current tabs:"
    " https://github.com/chrisbra/SaveSigns.vim
    " TODO consider saving and restoring the signs
    sign unplace *
    let s:number_of_tabs = len(gettabinfo())
    noautocmd call tab#TabDo("call s:PrintWindows(s:a_tab_nr, s:number_of_tabs)")
    let tab = input("Go to tab (".s:a_tab_nr."): ")
    let tab = substitute(tab,"[^0-9]","","g")
    if tab == ""
        return
    endif
    exe "tabn " . tab
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
