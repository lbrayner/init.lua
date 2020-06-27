" other

function! miscellaneous#SearchLastVisualSelectionNoMagic()
    normal! gvy
    let pattern = escape(@",'\/')
    exe "normal! /\\V" . pattern
    let @/="\\V" . pattern
endfunction

function! miscellaneous#FilterLine()
    let line = getline('.')
    let temp = tempname()
    exe 'sil! !'.escape(line,&shellxescape).' > '.temp.' 2>&1'
    if v:shell_error
        exe 'throw "'.escape(readfile(temp)[0],'"').'"'
    endif
    exe "sil! read ".fnameescape(temp)
    exe "sil call delete ('".temp."')"
endfunction

" XML

function! s:NavigateXmlNthParent(n)
    let n_command = "v" . (a:n+1) . "at"
    exec "silent normal! " . n_command . "vh"
endfunction

function! miscellaneous#NavigateXmlDepth(depth)
    if a:depth < 0
        call s:NavigateXmlNthParent(-a:depth)
        return
    endif
endfunction

function! miscellaneous#NavigateXmlDepthBackward(depth)
    call miscellaneous#NavigateXmlDepth(a:depth)
    call matchit#Match_wrapper('',1,'n')
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
