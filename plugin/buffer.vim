" TODO review these messy and confusing commands
command! -nargs=? -complete=filetype -bang BWipeFileType call buffer#BWipeFileType("<bang>", <f-args>)
command! -nargs=* -complete=file     -bang BWipeHidden   call buffer#BWipeHidden("<bang>", <q-args>)
command! -nargs=* -complete=file     -bang BWipeUnlisted call buffer#BWipeUnlisted("<bang>", <q-args>)
command! -nargs=1 -complete=file     -bang BWipe         call buffer#BWipe("<bang>", <q-args>)

command! -nargs=0       BWipeNotLoaded   call buffer#BWipeNotLoaded()
command! -nargs=0 -bang BWipeNotReadable call buffer#BWipeNotReadable("<bang>")

" Swap | File changes outside
" https://github.com/neovim/neovim/issues/2127
function! s:AS_HandleSwapfile (filename, swapname)
        " if swapfile is older than file itself, just get rid of it
        if getftime(v:swapname) < getftime(a:filename)
                call delete(v:swapname)
                let v:swapchoice = "e"
        endif
endfunction

augroup AutoSwap
        autocmd!
        autocmd SwapExists *  call s:AS_HandleSwapfile(expand("<afile>:p"), v:swapname)
        autocmd CursorHold,BufWritePost,BufReadPost,BufLeave *
                    \ if &buftype == "" | let &swapfile = &modified | endif
augroup END

" Check if file was modified outside this instance
augroup Checktime
    autocmd!
    autocmd VimEnter * autocmd! Checktime BufEnter,FocusGained,VimResume *
                \ if getcmdwintype() == "" | " Not done in the cmdline-window
                \     checktime |
                \ endif
augroup END
if v:vim_did_enter
    doautocmd Checktime VimEnter
endif

" Save any buffer

function! s:SaveAs(name,bang)
    try
        let lazyr = &lazyredraw
        set lazyredraw
        let buf_nr = bufnr("%")
        let temp_file = tempname()
        silent exec "write " . fnameescape(temp_file)
        enew
        normal! dG
        let new_buf_nr = bufnr("%")
        silent exec "read " . fnameescape(temp_file)
        1d_
        let write = "w"
        if a:bang
            let write = "w!"
        endif
        silent exec write . " " . fnameescape(a:name)
    finally
        let &lazyredraw = lazyr
        call delete(temp_file)
    endtry
endfunction

command! -nargs=1 -bang -complete=file SaveAs call s:SaveAs(<f-args>,<bang>0)

function! s:ReturnToOriginalWindow(current_window_id, last_accessed_window_id)
    let returnto_winnr = 0
    " Try to return to the last accessed window
    try
        let returnto_winnr = getwininfo(a:current_window_id)[0].winnr
        exe returnto_winnr . "wincmd w"
    catch
        " Try to return to the the window before that
        try
            let returnto_winnr = getwininfo(a:last_accessed_window_id)[0].winnr
            exe returnto_winnr . "wincmd w"
        catch
            " If all fails, do nothing
        endtry
    endtry
endfunction

" Close all local list windows

function! s:LCloseAllWindows(current_window_id, last_accessed_window_id)
    windo if util#isLocationList() | quit | endif
    call s:ReturnToOriginalWindow(a:current_window_id, a:last_accessed_window_id)
endfunction

command! LCloseAllWindows call s:LCloseAllWindows(win_getid(), win_getid(winnr("#")))

function! s:CloseAllHelp(current_window_id, last_accessed_window_id)
    windo if &buftype == "help" | quit | endif
    call s:ReturnToOriginalWindow(a:current_window_id, a:last_accessed_window_id)
endfunction

" Unclutter, i.e. close certain special windows

function! s:Unclutter(current_window_id,last_accessed_window_id)
    if util#WindowIsFloating()
        quit
        echo "Closed floating window."
        return
    endif
    " If we're in a help buffer, simply quit it
    if &buftype == "help"
        quit
        echo "Closed help."
        return
    endif
    if &previewwindow
        quit
        echo "Closed Preview window."
        return
    endif
    if util#isQuickfixOrLocationList()
        quit
        echo "Closed Quickfix or Location list window."
        return
    endif
    " If not in one, close all help buffers
    call s:CloseAllHelp(a:current_window_id, a:last_accessed_window_id)
    pclose " Close preview window
    cclose " Close quickfix window
    " Close all local lists
    call s:LCloseAllWindows(a:current_window_id, a:last_accessed_window_id)
    " Quit if there's at most one file and this is the last window
    " XXX: this is not lazy, quite expensive and O(n)
    if len(filter(range(1,bufnr("$")),"buflisted(v:val)")) <= 1 && winnr("$") == 1
        quit
    endif
    echo "Closed help, Preview, Quickfix or Location list window(s)."
endfunction

command! Unclutter call s:Unclutter(win_getid(), win_getid(winnr("#")))

nnoremap <F9> <Cmd>Unclutter<CR>

function! s:EchoClosedCmdline(...)
    echo "Closed Cmdline-window."
endfunction

function! s:UnclutterCmdline()
    quit
    " The same effect as lua's vim.schedule()
    call timer_start(0, funcref("<SID>EchoClosedCmdline"))
endfunction

augroup CmdwinClose
    autocmd!
    autocmd CmdwinEnter * nnoremap <buffer> <F9> <Cmd>call <SID>UnclutterCmdline()<CR>
augroup END
