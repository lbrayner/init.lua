" https://github.com/wincent/ferret: ferret#private#qargs()

function! s:QFBufnr2Bufname()
    let l:buffer_numbers={}
    for l:item in getqflist()
        let l:buffer_numbers[l:item["bufnr"]]=bufname(l:item["bufnr"])
    endfor
    return l:buffer_numbers
endfunction

" Return filenames currently in the quickfix window
function! s:QargsCommand()
  return join(map(values(s:QFBufnr2Bufname()), "fnameescape(v:val)"))
endfunction

function! s:QFYankFileNames()
    let @"=s:QargsCommand()
    if has("clipboard")
        let @+=@"
        let @*=@"
    endif
endfunction

function! s:QFWriteFileNames(filename)
    call writefile(values(s:QFBufnr2Bufname()),a:filename)
endfunction

function! s:SetupQuickfixBuffer()
    if util#isQuickfixList()
        command! -buffer -nargs=0 QFYankFileNames call <SID>QFYankFileNames()
        command! -buffer -nargs=1 -complete=file QFWriteFileNames call <SID>QFWriteFileNames(<f-args>)
    endif
endfunction

augroup QuickfixVimscriptBufferSetup
    autocmd!
    autocmd FileType qf call s:SetupQuickfixBuffer()
augroup END
