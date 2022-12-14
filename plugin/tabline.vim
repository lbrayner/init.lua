if !has("windows")
    finish
endif

set showtabline=2

function! RedefineTabline()
    " vim-obsession
    let this_session=substitute(v:this_session,'\.\d\+\.obsession\~',"","")
    " Is this a session?
    let session_name=this_session == "" ? "" :
                \ "(".fnamemodify(this_session,":t:r").")"
    let session=session_name == "" ? "" :
                \ "%#Question#" . session_name . "%#Normal# "
    " To be displayed on the left side
    let cwd=util#NPath(getcwd())
    let &tabline='%#Title#%4.{tabpagenr()}%#Normal# '.session.'%#NonText#'.cwd
    " At least one column separating left and right and a 1 column margin
    let max_length = &columns - 3 - 1 - 1 - len(session_name) - 1 - len(cwd) - 1 - 1
    " Fugitive blame
    if exists("*FugitiveResult") &&
                \has_key(FugitiveResult(bufnr()), "filetype") &&
                \has_key(FugitiveResult(bufnr()), "blame_file") &&
                \FugitiveResult(bufnr()).filetype == "fugitiveblame"
        let &tabline.=" %="
        let blame="Fugitive blame: "
        let max_length -= len(blame)
        let filename = FugitiveResult(bufnr()).blame_file
        let filename = util#truncateFilename(filename,max_length)
        let &tabline.="%#WarningMsg#".blame."%#Normal#".filename." "
        return
    endif
    " Fugitive temporary buffers
    if exists("*FugitiveResult") && len(FugitiveResult(bufnr()))
        let &tabline.=" %="
        let fcwd = FugitiveResult(bufnr()).cwd
        if !util#IsInDirectory(getcwd(), fcwd)
            let fcwd = util#NPath(fcwd)
            let max_length -= len(fcwd)
            let &tabline.="%<%#WarningMsg#".fcwd." "
        endif
        let &tabline.="%#Normal#".util#truncateFilename(expand("%"),max_length)." "
        return
    endif
    " Fugitive objects
    if exists("*FugitiveParse") && stridx(expand("%"),"fugitive://") == 0
        let [name, dir] = FugitiveParse(expand("%"))
        let dir = substitute(dir,'/\.git$',"","")
        " Fugitive summary
        if name ==# ":"
            let name = util#RelativeNode(dir, FugitiveReal(expand("%")))
        endif
        let &tabline.=" %="
        if !util#IsInDirectory(getcwd(), dir)
            let max_length -= len(name)
            let &tabline.="%#WarningMsg#".util#truncateFilename(
                        \util#NPath(dir),max_length)." "
        endif
        let &tabline.="%<%#Normal#".name." "
        return
    endif
    " jdtls
    if stridx(expand("%"),"jdt://") == 0
        let url = substitute(expand("%"), "?.*", "", "")
        let &tabline.=" %=%<%#Normal#".url." "
        return
    endif
    if &buftype ==# 'terminal'
        return
    endif
    let isabsolute=len(expand("%")) <= 0 ? 0 : !util#IsInDirectory(getcwd(), expand("%"))
    if isabsolute
        let absolute_path=util#truncateFilename(util#NPath(expand("%")),max_length)
        let &tabline=&tabline.' %=%#WarningMsg#'.absolute_path.' '
        return
    endif
    " At least one column separating left and right and a 1 column margin
    let relative_dir=util#truncateFilename(util#RelativeNode(getcwd(),
                \fnamemodify(expand("%:h"),":~")),max_length)
    let relative_dir = relative_dir == "." ? "" : relative_dir
    let &tabline=&tabline.' %#Directory#'.relative_dir.' '
endfunction

function! s:TablineBufEnter()
    if !exists("*nvim_win_get_config")
        call RedefineTabline()
        return
    endif
    if nvim_win_get_config(0).relative == ""
        call RedefineTabline()
    endif
endfunction

augroup Tabline
    autocmd!
    autocmd VimEnter * autocmd Tabline
                \ BufWritePost,WinEnter,DirChanged * call RedefineTabline()
    autocmd VimEnter * autocmd Tabline BufEnter * call s:TablineBufEnter()
    autocmd VimEnter * call RedefineTabline()
augroup END
if v:vim_did_enter
    doautocmd Tabline VimEnter
endif
