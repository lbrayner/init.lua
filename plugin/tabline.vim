if !has("windows")
    finish
endif

set showtabline=2

function! RedefineTabline()
    " Is this a session?
    let session_name=v:this_session == "" ? "" :
                \ "(".fnamemodify(v:this_session,":t:r").")"
    let session=session_name == "" ? "" :
                \ "%#Question#" . session_name . "%#Normal# "
    " To be displayed on the left side
    let cwd=substitute(fnamemodify(getcwd(),":~"),'/$',"","")
    " At least one column separating left and right and a 1 column margin
    let max_length = &columns - 3 - 1 - 1 - len(session_name) - 1 - len(cwd) - 1 - 1
    " Is it outside of cwd? Recent versions of getcwd() return paths with backward
    " slashes on win32
    " Similar to Java's String.startsWith
    let isabsolute=len(expand("%")) <= 0 ? 0
                \: stridx(expand("%:p"),fnamemodify(getcwd(),":p:gs?\\?/?")) != 0
    let &tabline='%#Title#%4.{tabpagenr()}%#Normal# '.session
                \ .'%#NonText#'.cwd
    if &buftype ==# 'terminal'
        return
    endif
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
