function! Path()
    if len(expand("%")) <= 0
        return ""
    endif
    if !util#IsInDirectory(getcwd(), expand("%"), 1)
        return FullPath()
    endif
    return expand("%:.")
endfunction

function! FullPath()
    return expand("%:~")
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

function! Clip(...)
    if a:0 > 0
        let text = a:1
        if type(a:1) != type("")
            let text = string(a:1)
        endif
        let @"=text
    endif
    let @+=@" | let @*=@"
    echo getreg('"')
endfunction

" Copies arg to the system's clipboard
command! -nargs=? Clip call Clip(<f-args>)

command! Path call Clip(Path())
command! FullPath call Clip(FullPath())
command! Name call Clip(Name())
command! Cwd call Clip(Cwd())
command! Directory call Clip(Directory())
command! RelativeDirectory call Clip(RelativeDirectory())
