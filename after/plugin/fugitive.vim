if !exists("*FugitiveParse")
    finish
endif

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

if exists("*Clip")
    command! -nargs=0 FObject call Clip(FObject())
    command! -nargs=0 FPath call Clip(FPath())
endif

cnoreabbrev Gb Git blame --abbrev=6
cnoreabbrev Gd Git difftool -y
" To list files modified by a range of commits
cnoreabbrev Gdn Git diff --name-only --stat
cnoreabbrev Gl Git log
cnoreabbrev Glns Git log --name-status
cnoreabbrev Glo Git log --oneline
" To list branches of a specific remote: Git! ls-remote upstream
cnoreabbrev Gr Git! ls-remote

function! s:FugitiveMapOverrides()
    " So we can jump with 'switchbuf'
    sil! exe "nunmap <buffer> <C-W>f"
    " So we can open in a new tab
    sil! exe "nunmap <buffer> <C-W>gf"
    " So we can use Nvim builtin search selected
    sil! exe "vunmap <buffer> *"
endfunction

augroup FugitiveCustomAutocommands
    autocmd!
    autocmd FileType fugitive Glcd
    autocmd BufEnter fugitive://*//* setlocal nomodifiable
    autocmd FileType fugitive,gitcommit,git call s:FugitiveMapOverrides()
augroup END
