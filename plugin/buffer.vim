command! BufWipeNotLoaded call buffer#BufWipeNotLoaded()
command! BufWipeTab call buffer#BufWipeTab()
command! -nargs=1 BufWipe call buffer#BufWipe(<f-args>)
command! -nargs=1 BufWipeForce call buffer#BufWipeForce(<f-args>)
command! -nargs=1 BufWipeForceUnlisted call buffer#BufWipeForceUnlisted(<f-args>)
command! -nargs=1 BufWipeHidden call buffer#BufWipeHidden(<f-args>)
command! BufWipeTabOnly call buffer#BufWipeTabOnly()
command! -nargs=1 BufWipeFileType call buffer#BufWipeFileType(<f-args>)

" Swap | File changes outside
" https://github.com/neovim/neovim/issues/2127
augroup AutoSwap
        autocmd!
        autocmd SwapExists *  call s:AS_HandleSwapfile(expand('<afile>:p'), v:swapname)
augroup END

function! s:AS_HandleSwapfile (filename, swapname)
        " if swapfile is older than file itself, just get rid of it
        if getftime(v:swapname) < getftime(a:filename)
                call delete(v:swapname)
                let v:swapchoice = 'e'
        endif
endfunction
autocmd CursorHold,BufWritePost,BufReadPost,BufLeave *
  \ if isdirectory(expand("<amatch>:h")) | let &swapfile = &modified | endif

augroup Checktime
    autocmd!
    if !has("gui_running")
        "silent! necessary otherwise throws errors when using command
        "line window.
        autocmd BufEnter,CursorHold,CursorHoldI,CursorMoved
                    \,CursorMovedI,FocusGained,BufEnter,FocusLost,WinLeave *
                    \ sil! exe "checktime"
    endif
augroup END

" Save any buffer

function! s:Save(name,bang)
    try
        let lazyr = &lazyredraw
        let buf_nr = bufnr('%')
        let win_height = winheight(0)
        set lazyredraw
        let temp_file = tempname()
        silent exec 'write ' . fnameescape(temp_file)
        keepalt new
        let new_buf_nr = bufnr('%')
        silent exec "read " . fnameescape(temp_file)
        1d_
        let write = "w"
        if a:bang
            let write = "w!"
        endif
        silent exec write . " " . fnameescape(a:name)
        edit
        exec bufwinnr(buf_nr)."wincmd w"
        quit
        exec bufwinnr(new_buf_nr)."wincmd w"
        silent exec "resize " . win_height
    finally
        let &lazyredraw = lazyr
        call delete(temp_file)
    endtry
endfunction

command! -nargs=1 -bang -complete=file Save call s:Save(<f-args>,<bang>0)
