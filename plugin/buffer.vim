" TODO review these messy and confusing commands
command! -nargs=1 -complete=file     BWipe              call buffer#BWipe(<f-args>)
command! -nargs=1 -complete=filetype BWipeFileType      call buffer#BWipeFileType(<f-args>)
command! -nargs=* -complete=file     BWipeHidden        call buffer#BWipeHidden(<q-args>)
command! -nargs=1 -complete=file     BWipeForce         call buffer#BWipeForce(<f-args>)
command! -nargs=1 -complete=file     BWipeForceUnlisted call buffer#BWipeForceUnlisted(<f-args>)

command! -nargs=0 BWipeNotLoaded        call buffer#BWipeNotLoaded()
command! -nargs=0 BWipeNotReadable      call buffer#BWipeNotReadable()
command! -nargs=0 BWipeNotReadableForce call buffer#BWipeNotReadableForce()

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
                    \ if isdirectory(expand("<amatch>:h")) | let &swapfile = &modified | endif
augroup END

" Check if file was modified outside this instance
augroup Checktime
    autocmd!
    if !has("gui_running")
        "silent! necessary otherwise throws errors when using command
        "line window.
        autocmd VimEnter * autocmd! Checktime BufEnter,CursorHold,CursorHoldI,CursorMoved,
                    \CursorMovedI,FocusGained,BufEnter,FocusLost,WinLeave *
                    \ sil! exe "checktime"
    endif
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

function! s:ReturnToOriginalWindow(current_window_id, last_accessed_winnr)
    let lastwinnr = winnr("$")
    let returnto_winnr = 0
    try
        let returnto_winnr = getwininfo(a:current_window_id)[0].winnr
        exe returnto_winnr . "wincmd w"
    catch
        let returnto_winnr = a:last_accessed_winnr
        silent! exe returnto_winnr . "wincmd w"
    finally
        if returnto_winnr >= lastwinnr
            doautocmd WinEnter
        endif
    endtry
endfunction

" Close all local list windows

function! s:LCloseAllWindows(current_window_id, last_accessed_winnr)
    if util#isLocationList()
        " Autocommands are triggered normally
        windo lclose
    else
        noautocmd windo lclose
    endif
    call s:ReturnToOriginalWindow(a:current_window_id, a:last_accessed_winnr)
endfunction

command! LCloseAllWindows call s:LCloseAllWindows(win_getid(),winnr("#"))

function! s:CloseAllHelp(current_window_id, last_accessed_winnr)
    noautocmd windo if &ft == "help" | quit | endif
    call s:ReturnToOriginalWindow(a:current_window_id, a:last_accessed_winnr)
endfunction

" Unclutter, i.e. close certain special windows

function! s:Unclutter(current_window_id,last_accessed_winnr)
    " Close current window if it's a floating one
    if exists("*nvim_win_get_config") && nvim_win_get_config(0).relative != ""
        quit
        return
    endif
    " If we're in a help buffer, simply quit it
    if &ft == "help"
        quit
        return
    endif
    if &previewwindow
        quit
        return
    endif
    if util#isQuickfixOrLocationList()
        quit
        return
    endif
    " If not in one, close all help buffers
    call s:CloseAllHelp(a:current_window_id, a:last_accessed_winnr)
    pclose " Close preview window
    cclose " Close quickfix window
    " Close all local lists
    call s:LCloseAllWindows(a:current_window_id, a:last_accessed_winnr)
    " Quit if there's at most one file and this is the last window
    " XXX: this is not lazy, quite expensive and O(n)
    if len(filter(range(1,bufnr("$")),"buflisted(v:val)")) <= 1 && winnr("$") == 1
        quit
    endif
endfunction

command! Unclutter silent call s:Unclutter(win_getid(),winnr("#"))

nnoremap <F9> <Cmd>Unclutter<CR>

augroup CmdwinClose
    autocmd!
    autocmd CmdwinEnter * nnoremap <buffer> <F9> <Cmd>q<CR>
augroup END
