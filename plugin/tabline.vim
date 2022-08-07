if !has("windows")
    finish
endif

set showtabline=2

" Normalized path
" Recent versions of getcwd() return paths with backward slashes on win32
function s:NPath(path)
    return fnamemodify(a:path,":p:gs?\\?/?:s?/$??:~")
endfunction

function! s:IsInDirectory(directory, node)
    " Think Java's String.startsWith
    return stridx(s:NPath(a:node), s:NPath(a:directory)) == 0
endfunction

function! RedefineTabline()
    " vim-obsession
    let this_session=substitute(v:this_session,'\.\d\+\.obsession\~',"","")
    " Is this a session?
    let session_name=this_session == "" ? "" :
                \ "(".fnamemodify(this_session,":t:r").")"
    let session=session_name == "" ? "" :
                \ "%#Question#" . session_name . "%#Normal# "
    " To be displayed on the left side
    let cwd=s:NPath(getcwd())
    " At least one column separating left and right and a 1 column margin
    let max_length = &columns - 3 - 1 - 1 - len(session_name) - 1 - len(cwd) - 1 - 1
    let &tabline='%#Title#%4.{tabpagenr()}%#Normal# '.session
                \ .'%#NonText#'.cwd
    if exists("*FugitiveResult") && len(FugitiveResult(bufnr()))
        let &tabline.="%="
        let fcwd = FugitiveResult(bufnr()).cwd
        if !s:IsInDirectory(getcwd(), fcwd)
            let &tabline.="%#WarningMsg#".s:NPath(fcwd)." "
        endif
        let &tabline.="%#Normal#".expand("%")." "
        return
    endif
    if exists("*FugitiveParse") && stridx(expand("%"),"fugitive://") == 0
        let [rev, dir] = FugitiveParse(expand("%"))
        let &tabline.="%="
        if !s:IsInDirectory(getcwd(), dir)
            let &tabline.="%#WarningMsg#".s:NPath(dir)." "
        endif
        let &tabline.="%#Normal# ".rev." "
        return
    endif
    if &buftype ==# 'terminal'
        return
    endif
    let isabsolute=len(expand("%")) <= 0 ? 0 : !s:IsInDirectory(getcwd(), expand("%"))
    if isabsolute
        let absolute_path=util#truncateFilename(fnamemodify(expand("%"),":p:~"),max_length)
        let &tabline=&tabline.'%=%#WarningMsg# '.absolute_path.' '
        return
    endif
    " At least one column separating left and right and a 1 column margin
    let relative_dir=util#truncateFilename(substitute(
                \fnamemodify(expand("%:h"),":~"),'\V'.cwd.'/\?',"",""),max_length)
    let relative_dir = relative_dir == "." ? "" : relative_dir
    let &tabline=&tabline.'%#Directory# '.relative_dir.' '
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
