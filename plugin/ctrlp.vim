if executable("fzf")
    finish
endif

let g:ctrlp_cache_dir = stdpath("cache")."/ctrlp_cache"
if !isdirectory(g:ctrlp_cache_dir)
    call mkdir(g:ctrlp_cache_dir)
endif
let g:ctrlp_working_path_mode = ""
let g:ctrlp_reuse_window = 'netrw\|help'
let g:extensions#ctrlp#ctrlp_custom_ignore = {
            \ "file": '\v\.o$|\.exe$|\.lnk$|\.bak$|\.sw[a-z]$|\.class$|\.jasper$'
            \               . '|\.r[0-9]+$|\.mine$',
            \ "dir": '\C\V' . escape(expand("~"),' \') . '\$' . '\|ctrlp_cache\$'
            \ }

let g:ctrlp_custom_ignore = {
            \ "func": "extensions#ctrlp#ignore"
            \ }
let g:ctrlp_switch_buffer = "t"
let g:ctrlp_map = "<F7>"
let g:ctrlp_tabpage_position = "bc"
let g:ctrlp_clear_cache_on_exit = 0
" Copied from the help file
let g:ctrlp_prompt_mappings = {
            \ 'PrtSelectMove("j")':   ['<c-n>', '<down>'],
            \ 'PrtSelectMove("k")':   ['<c-p>', '<up>'],
            \ 'PrtHistory(-1)':       ['<c-j>'],
            \ 'PrtHistory(1)':        ['<c-k>'],
            \ }

nnoremap <F5> <Cmd>CtrlPBuffer<CR>

packadd! ctrlp.vim
