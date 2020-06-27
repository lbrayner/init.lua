" other

function! miscellaneous#SearchLastVisualSelectionNoMagic()
    normal! gvy
    let pattern = escape(@",'\/')
    exe "normal! /\\V" . pattern
    let @/="\\V" . pattern
endfunction

" OverLength

highlight OverLength ctermbg=red ctermfg=white guibg=#592929

function! miscellaneous#HighlightOverLength()
    if ! exists("s:OverLength")
        let s:OverLength = 90
    endif
    if ! exists("w:HighlightOverLengthFlag")
        let w:HighlightOverLengthFlag = 1
    endif
    if w:HighlightOverLengthFlag
        exec 'match OverLength /\%' . s:OverLength . 'v.\+/'
        echo "Overlength highlighted."
    else
        exec "match"
        echo "Overlength highlight cleared."
    endif
    let w:HighlightOverLengthFlag = ! w:HighlightOverLengthFlag
endfunction

" Save any buffer

function! miscellaneous#Save(name,bang)
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
