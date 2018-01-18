" http://vim.wikia.com/wiki/Autocmd_to_update_ctags_file
function! s:DelTagOfFile(file)
    if executable("sed")
        let fullpath = a:file
        let tagfilename = getcwd() . "/tags"
        let f = substitute(fullpath, getcwd() . "/", "", "")
        let f = escape(f, './')
        let cmd = 'sed -i "/' . f . '/d" "' . tagfilename . '"'
        let resp = system(cmd)
    endif
endfunction

function! ctags#UpdateTags()
    if filereadable("tags")
        let tagfilename = "tags"
        let cmd = 'ctags -a -f ' . tagfilename . " " . shellescape(expand("%"))
        call s:DelTagOfFile(expand("%:p"))
        let resp = system(cmd)
    endif
endfunction
