if !exists("*FugitiveParse")
    finish
endif

augroup FugitiveCustomAutocommands
    autocmd!
    autocmd FileType fugitive Glcd
    autocmd BufEnter fugitive://*//* setlocal nomodifiable
augroup END

command! -bar -bang -nargs=* -complete=customlist,fugitive#EditComplete Gdi
            \ exe fugitive#Diffsplit(1, <bang>0, "leftabove <mods>", <q-args>)
function! FObject()
    return FugitiveParse(expand("%"))[0]
endfunction
function! FPath()
    return fnamemodify(FugitiveReal(expand("%")),":~:.")
endfunction

command! -nargs=0 FObject :let @"=FObject()
command! -nargs=0 FPath :let @"=FPath()

cnoreabbrev Gd Git difftool -y
cnoreabbrev Gl Git log
cnoreabbrev Glns Git log --name-status
cnoreabbrev Glo Git log --oneline
" To list branches of a specific remote: Git! ls-remote upstream
cnoreabbrev Gr Git! ls-remote

if !exists("*Clip")
    finish
endif

command! -nargs=0 FObject call Clip(FObject())
command! -nargs=0 FPath call Clip(FPath())
