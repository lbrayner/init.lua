function! Path()
    if len(expand("%")) <= 0
        return ""
    endif
    if !util#IsInDirectory(getcwd(), expand("%"))
        return FullPath()
    endif
    return expand("%")
endfunction

function! FullPath()
    return expand("%:p:~")
endfunction

function! Name()
    return expand("%:t")
endfunction

function! Cwd()
    return fnamemodify(getcwd(),":~")
endfunction

function! Directory()
    return fnamemodify(expand("%"),":~:h")
endfunction

function! RelativeDirectory()
    return fnamemodify(expand("%"),":h")
endfunction

command! Path let @"=Path()
command! FullPath let @"=FullPath()
command! Name let @"=Name()
command! Cwd let @"=Cwd()
command! Directory let @"=Directory()
command! RelativeDirectory let @"=RelativeDirectory()

if !has("clipboard")
    finish
endif

function! Clip(...)
    if a:0 > 0
        let text = a:1
        if type(a:1) != type("")
            let text = string(a:1)
        endif
        let @"=text
    endif
    let @+=@" | let @*=@"
    if len(getreg('"',1,1)) == 1 && len(getreg('"',1,1)[0]) <= &columns*0.9
        echo getreg('"',1,1)[0]
    elseif len(getreg('"',1,1)) == 1
        echo "1 line clipped"
    else
        echo len(getreg('"',1,1)) . " lines clipped"
    endif
endfunction

" Copies arg to the system's clipboard
command! -nargs=? Clip call Clip(<f-args>)

vnoremap <Leader>c y<Cmd>Clip<CR>

nnoremap <Leader>p "+p
vnoremap <Leader>p "+p

command! Path call Clip(Path())
command! FullPath call Clip(FullPath())
command! Name call Clip(Name())
command! Cwd call Clip(Cwd())
command! Directory call Clip(Directory())
command! RelativeDirectory call Clip(RelativeDirectory())
