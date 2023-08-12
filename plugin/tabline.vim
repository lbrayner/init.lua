set showtabline=2

function! RedefineTabline()
    " Is this a session?
    let session_name=util#getSession()
    let session=session_name == "" ? "" :
                \ "%#Question#" . "(" . session_name . ")" . "%#Normal# "
    " To be displayed on the left side
    let cwd=util#NPath(getcwd())
    let &tabline="%#Title#%4.{tabpagenr()}%#Normal# ".session."%#NonText#".cwd
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
    if exists("*FugitiveParse") && len(FObject()) " Fugitive objects
        let [name, dir] = FugitiveParse(expand("%"))
        let dir = substitute(dir,'/\.git$',"","")
        " Fugitive summary
        let &tabline.=" %="
        if !util#IsInDirectory(getcwd(), dir)
            let &tabline.="%#WarningMsg#".util#truncateFilename(
                        \util#NPath(dir),max_length)." "
        endif
        return
    endif
    " jdtls
    if stridx(expand("%"),"jdt://") == 0
        return
    endif
    if &buftype ==# "terminal"
        return
    endif
    let isabsolute=len(expand("%")) <= 0 ? 0 : !util#IsInDirectory(getcwd(), expand("%"))
    if isabsolute
        let absolute_path=util#truncateFilename(util#NPath(expand("%")),max_length)
        let &tabline=&tabline." %=%#WarningMsg#".absolute_path." "
        return
    endif
endfunction

function! s:TablineBufEnter()
    if util#WindowIsFloating()
        return
    endif
    call RedefineTabline()
endfunction

augroup Tabline
    autocmd!
    autocmd VimEnter * autocmd Tabline
                \ BufFilePost,BufWritePost,DirChanged,WinEnter * call RedefineTabline()
    autocmd VimEnter * autocmd Tabline BufEnter * call s:TablineBufEnter()
    autocmd VimEnter * call RedefineTabline()
augroup END
if v:vim_did_enter
    doautocmd Tabline VimEnter
endif
