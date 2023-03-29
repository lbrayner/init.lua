" inferring where we are

if $XDG_CONFIG_HOME == ""
    let $XDG_CONFIG_HOME = "~/.config"
    let $XDG_CONFIG_HOME = fnamemodify($XDG_CONFIG_HOME,":p")
endif

if !exists("g:vim_dir") || g:vim_dir == ""
    let g:vim_dir = $XDG_CONFIG_HOME . "/nvim"

    if $MYVIMRC == ""
        let g:vim_dir = expand("<sfile>:p:h")
    endif
endif

" Subsection: settings {{{

set encoding=utf-8
filetype plugin indent on
set nocompatible
syntax on

if stridx($TERM, "256color") >= 0
    set termguicolors
endif

set laststatus=2
set listchars=eol:¬,tab:»\ ,trail:·
set splitbelow
set splitright
set number
set relativenumber
set wildmode=longest:full
set wildmenu
if has("linebreak")
    set breakindent
endif
set linebreak
set autoindent
set hlsearch
set hidden
set nostartofline
set fileformats=unix,dos
set fileformat=unix
set backspace=indent,eol,start
set incsearch
set nojoinspaces
set ignorecase
set smartcase
set noruler
set lazyredraw
set title
set noshowmode

"show existing tab with 4 spaces width
set tabstop=4
" when indenting with '>', use 4 spaces width
set shiftwidth=4
set expandtab

set mouse=a

" are we using ssh?
let g:ssh_client = 0

if $SSH_CLIENT != ""
    let g:ssh_client = 1
endif

" mouse selection yanks to the system clipboard when using ssh
if g:ssh_client
    set mouse=
endif

" setting backupdir

let s:bkp_dir = g:vim_dir."/backup"
exe "let s:has_bkp_dir = isdirectory('".s:bkp_dir."')"
if !s:has_bkp_dir
    call mkdir(s:bkp_dir)
endif
let &backupdir=s:bkp_dir."/"

" See backup in editing.txt
" So that watchprocesses work as expected
set backupcopy=yes

" diff & patch

" Microsoft Windows standard input converts line endings, so it's best to
" avoid using it
set patchexpr=MyPatch()
function MyPatch()
   :call system("patch -o " . v:fname_out . " " . v:fname_in .
               \ " " . v:fname_diff)
endfunction

command! MergeMarkers call quickfix#ilist_search(0
            \,"^\\(<<<<<<<\\||||||||\\|=======\\|>>>>>>>\\)",1,0)

" From tpope's vim-sensible
if &synmaxcol == 3000
  " Lowering this improves performance in files with long lines.
  set synmaxcol=500
endif

" }}}

" Subsection: mappings — pt-BR keyboard {{{1

" disable Ex mode mapping
nmap Q <nop>

" cedilla is right where : is on an en-US keyboard
nnoremap ç :
vnoremap ç :
nnoremap Ç :<Up><CR>
vnoremap Ç :<Up><CR>
nnoremap ¬ ^
nnoremap qç q:
vnoremap qç q:
vnoremap ¬ ^

nnoremap <Space>o <Cmd>only<CR>

" clear search highlights

nnoremap <silent> <F2> <Cmd>set invhlsearch hlsearch?<CR>

" easier window switching
nnoremap <C-H> <C-W>h
nnoremap <C-J> <C-W>j
nnoremap <C-K> <C-W>k
nnoremap <C-L> <C-W>l

vnoremap <C-H> <Esc><C-W>h
vnoremap <C-J> <Esc><C-W>j
vnoremap <C-K> <Esc><C-W>k
vnoremap <C-L> <Esc><C-W>l

" splits
nnoremap <Leader>v <C-W>v
nnoremap <Leader>h <C-W>s

nnoremap <Leader>i <Cmd>set invpaste paste?<CR>

nnoremap <Leader><F5> <Cmd>ls<CR><Cmd>buffer<Space>
nnoremap <F6> <Cmd>w<CR>
inoremap <F6> <Esc><Cmd>w<CR>
vnoremap <F6> <Esc><Cmd>w<CR>
nnoremap <Leader><F6> <Cmd>w!<CR>
nnoremap <silent> <F12> <Cmd>setlocal list!<CR>
inoremap <silent> <F12> <Cmd>setlocal list!<CR>
vnoremap . <Cmd>normal .

" previous buffer
nnoremap <Space>b <Cmd>b#<CR>

" quickfix and locallist

nnoremap <silent> <Space>l <Cmd>botright lopen<CR>
nnoremap <silent> <Space>q <Cmd>botright copen<CR>

" force case sensitivity for *-search
nnoremap <Plug>CaseSensitiveStar /\C\V\<<c-r>=expand("<cword>")<cr>\><cr>
nmap * <Plug>CaseSensitiveStar

" sometimes you want to search with no noincsearch set

function! s:NoIncSearchEnd()
    if !exists("s:incsearch")
        return
    endif
    let &incsearch = s:incsearch
endfunction

function! s:NoIncSearchStart(pattern)
    let s:incsearch = &incsearch
    set noincsearch
    exe "autocmd CmdlineLeave ".a:pattern." ++once call s:NoIncSearchEnd()"
endfunction

nnoremap <Leader>/ <Cmd>call <SID>NoIncSearchStart("/")<CR>/
nnoremap <Leader>? <Cmd>call <SID>NoIncSearchStart("?")<CR>?

" Neovim terminal

" Case matters for keys after alt or meta
tnoremap <A-h> <C-\><C-N><C-W>h
tnoremap <A-j> <C-\><C-N><C-W>j
tnoremap <A-k> <C-\><C-N><C-W>k
tnoremap <A-l> <C-\><C-N><C-W>l
nnoremap <A-h> <C-W>h
nnoremap <A-j> <C-W>j
nnoremap <A-k> <C-W>k
nnoremap <A-l> <C-W>l

" Emacs-style editing in command-line mode and insert mode
" Case matters for keys after alt or meta

" start of line
cnoremap <C-A> <Home>
" back one character
cnoremap <C-B> <Left>
" delete character under cursor
cnoremap <C-D> <Del>
" end of line
cnoremap <C-E> <End>
" open the command line buffer
cnoremap <C-X> <C-F>
" forward one character
cnoremap <C-F> <Right>
" recall newer command-line
cnoremap <M-n> <Down>
" recall previous (older) command-line
cnoremap <M-p> <Up>
" cancel
cnoremap <C-G> <C-C>
" forward word
cnoremap <M-f> <S-Right>
" backward a word
cnoremap <M-b> <S-Left>
" kill word
cnoremap <M-d> <C-F>ea<C-W><C-C>
" kill line
cnoremap <C-K> <C-F>D<C-C><Right>
" forward a word
inoremap <M-f> <C-Right>
" backward a word
inoremap <M-b> <C-Left>
" kill word
inoremap <M-d> <C-O>e<C-O>a<C-W>
" kill line
inoremap <C-K> <C-O>D
" remapping digraph
inoremap <C-B> <C-K>

" inserting the current line
cnoremap <C-R><C-L> <C-R>=getline(".")<CR>
" inserting the current line number
cnoremap <C-R><C-N> <C-R>=line(".")<CR>

" diff & patch

function! s:ToggleIWhite()
    if &l:diffopt =~# "iwhite"
        set diffopt-=iwhite
        echo "-iwhite"
        return
    endif
    set diffopt+=iwhite
    echo "+iwhite"
endfunction

nnoremap <Leader>do <Cmd>diffoff!<CR>
nnoremap <Leader>di <Cmd>call <SID>ToggleIWhite()<CR>

" Insert timestamps

imap <F3> <C-R>=strftime("%Y-%m-%d %a %0H:%M")<CR>

" tabs

" This mapping is overridden by packages
if !v:vim_did_enter
    if exists("*gettabinfo")
        nmap <F8> <Plug>GoToTab
    else
        nmap <F8> :tabs<cr>
    endif
endif

" }}}

" Subsection: functions & commands

" Clear the Quickfix List

function s:ClearQuickfixList()
  call setqflist([])
endfunction

command! ClearQuickfixList call s:ClearQuickfixList()

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

if has("clipboard")
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

    nnoremap <Leader>c <Cmd>Clip<CR>
    vnoremap <Leader>c y<Cmd>Clip<CR>

    nnoremap <Leader>p "+p
    vnoremap <Leader>p "+p

    command! Path call Clip(Path())
    command! FullPath call Clip(FullPath())
    command! Name call Clip(Name())
    command! Cwd call Clip(Cwd())
    command! Directory call Clip(Directory())
    command! RelativeDirectory call Clip(RelativeDirectory())
else
    command! Path let @"=Path()
    command! FullPath let @"=FullPath()
    command! Name let @"=Name()
    command! Cwd let @"=Cwd()
    command! Directory let @"=Directory()
    command! RelativeDirectory let @"=RelativeDirectory()
endif

command! -nargs=0 -bar -range=% DeleteTrailingWhitespace
            \ call util#PreserveViewPort("keeppatterns ".<line1>.",".<line2>.'s/\s\+$//e')
cnoreabbrev D DeleteTrailingWhitespace

command! -bar -range AllLowercase call util#PreserveViewPort(
            \"keeppatterns ".<line1>.",".<line2>.'s/.*/\L&/g')
command! -nargs=0 -bar -range=% Capitalize
            \ call util#PreserveViewPort(
            \     "keeppatterns ".<line1>.",".<line2>.'s/\<./\u&/ge')

command! Lcd lcd %
cnoreabbrev L Lcd
command! Tcd tcd %
cnoreabbrev T Tcd

command! -nargs=1 FileSearch call quickfix#ilist_search(0,<f-args>,1,1)

function! s:ToggleNumber()
    if !&number
        set relativenumber number
        return
    endif
    if !&relativenumber
        set norelativenumber nonumber
        return
    endif
    set norelativenumber number
endfunction

command! -nargs=0 ToggleNumber call s:ToggleNumber()

function! s:Number()
    set number
    set relativenumber
    " setting nonumber if length of line count is greater than 3
    if len(line("$"))>3
        set nonumber
    endif
endfun

command! -nargs=0 Number call s:Number()

" https://vi.stackexchange.com/a/36414
function! s:Source(line_start, line_end, ...)
    let tempfile = tempname()
    if a:0 > 0 && a:1 " Lua code
        let tempfile.=".lua"
    endif
    sil exe a:line_start.",".a:line_end."write ".fnameescape(tempfile)
    try
        exe "source ".fnameescape(tempfile)
        call delete(tempfile)
        if a:line_start == a:line_end
            echom "Sourced line ".a:line_start."."
            return
        endif
        echom "Sourced lines ".a:line_start." to ".a:line_end."."
    endtry
endfunction

command! -nargs=0 -range Source call s:Source(<line1>, <line2>)
command! -nargs=0 -range LuaSource call s:Source(<line1>, <line2>, 1)

function! s:Filter(line_start,line_end)
    let offset = 0
    for linenr in range(a:line_start,a:line_end)
        call cursor(linenr+offset,0)
        let output = systemlist(getline(linenr+offset))
        exe "delete"
        call append(linenr+offset-1,output)
        if len(offset) > 0
            let offset += len(output) - 1
        endif
    endfor
    call cursor(a:line_start,0)
endfunction

command! -nargs=0 -range Filter call s:Filter(<line1>,<line2>)

command! -nargs=0 -range Execute <line1>,<line2>w !$SHELL

" Overlength

function! s:OverlengthToggle()
    if !exists("w:Overlength")
        let w:Overlength = 90
    endif
    if !exists("w:HighlightOverlengthFlag")
        let w:HighlightOverlengthFlag = 1
    endif
    if w:HighlightOverlengthFlag
        highlight Overlength ctermbg=red ctermfg=white guibg=#592929
        exec 'match Overlength /\%' . w:Overlength . 'v.\+/'
        echo "Overlength highlighted."
    else
        exec "match"
        echo "Overlength highlight cleared."
    endif
    let w:HighlightOverlengthFlag = ! w:HighlightOverlengthFlag
endfunction

command! -nargs=0 OverlengthToggle call s:OverlengthToggle()

function! s:SearchLastVisualSelectionNoMagic()
    normal! gvy
    let pattern = escape(@",'\/')
    let @/="\\V".pattern
    exe "/\\V".pattern
    normal! Nn
endfunction

command! -nargs=0 -range SearchVisualSelectionNoMagic
            \ call s:SearchLastVisualSelectionNoMagic()

if executable("svn")
    command! Scursor call subversion#SVNDiffCursor()
    command! Sthis call subversion#SVNDiffThis()
    command! Sdiff call subversion#SVNDiffContextual()
endif

function! s:Synstack()
    echo map(synstack(line("."), col(".")),"synIDattr(v:val, 'name')")
endfunction

" Human-readable stack of syntax items
command! -nargs=0 -range Synstack call s:Synstack()

" Subsection: autocmds {{{

" Command-line Window

augroup CmdWindow
    autocmd!
    autocmd CmdwinEnter * setlocal nospell
augroup END

" idle

function! s:InsertModeUndoPoint()
    if mode() != "i"
        return
    endif
    call feedkeys("\<c-g>u")
endfunction

augroup InsertModeUndoPoint
    autocmd!
    autocmd CursorHoldI * call s:InsertModeUndoPoint()
augroup END

" buffer aesthetics

augroup AestheticsAutoGroup
    autocmd!
    autocmd VimEnter * autocmd AestheticsAutoGroup
                \ BufRead,BufEnter,BufWritePost * call s:Number()
    autocmd VimEnter * call s:Number()
    autocmd FileType help autocmd! AestheticsAutoGroup BufEnter <buffer> set relativenumber
augroup END
if v:vim_did_enter
    doautocmd AestheticsAutoGroup VimEnter
endif

" comment string

augroup PoundComment
    autocmd!
    autocmd FileType apache,crontab,debsources,desktop,fstab,samba
                \ autocmd! PoundComment BufEnter <buffer> ++once let &l:commentstring = "# %s"
augroup END

" svn commit files

augroup SvnFtGroup
    autocmd!
    autocmd BufEnter *.svn set ft=svn
augroup END

" vidir

augroup VidirGroup
    autocmd!
    autocmd BufEnter /tmp/dir*
                \ if argc() == 1 && argv(0) =~# '^/tmp/dir\w\{5}$' |
                \     set ft=vidir |
                \ endif
augroup END

" infercase

augroup InferCaseGroup
    autocmd!
    autocmd FileType markdown,gitcommit,text,svn,mail setlocal ignorecase infercase
augroup END

" XML

let s:LargeXmlFile = 1024 * 512
augroup LargeXmlAutoGroup
    autocmd BufRead * if &filetype =~# '\v(xml|html)'
            \| if getfsize(expand("<afile>")) > s:LargeXmlFile
                \| setlocal syntax=unknown | endif | endif
augroup END

augroup XmlFtGroup
    autocmd!
    autocmd BufEnter *.wsdl set ft=xml " Web Services Description Language
augroup END

function! s:XmlBufferSetup()
    let b:delimitMate_matchpairs = "(:),[:],{:},<:>"
    let b:surround_indent = 0
    nnoremap <buffer> <silent> [< <Cmd>call xml#NavigateDepthBackward(v:count1)<CR>
    nnoremap <buffer> <silent> ]> <Cmd>call xml#NavigateDepth(v:count1)<CR>
endfunction

augroup XmlBufferSetup
    autocmd!
    autocmd FileType html,xml call s:XmlBufferSetup()
augroup END

function! s:JSReactBufferSetup()
    nnoremap <buffer> <silent> [< <Cmd>call xml#NavigateDepthBackward(v:count1)<CR>
    nnoremap <buffer> <silent> ]> <Cmd>call xml#NavigateDepth(v:count1)<CR>
endfunction

augroup JSReactBufferSetup
    autocmd!
    autocmd FileType javascriptreact,typescriptreact call s:JSReactBufferSetup()
augroup END

" text format options

augroup DefaultFileType
    autocmd BufEnter *
                \ if &filetype == "" |
                \     set ft=text | let b:default_filetype = 1 |
                \ endif
augroup END

augroup DetectFileType
    autocmd BufWritePre *
                \ if exists("b:default_filetype") |
                \     setlocal infercase< | setlocal textwidth< | filetype detect |
                \     unlet b:default_filetype |
                \ endif
augroup END

augroup TextFormatAutoGroup
    autocmd!
    autocmd FileType text,svn setlocal textwidth=80
augroup END

augroup LuaAutoGroup
    autocmd!
    autocmd FileType lua setlocal shiftwidth=2
augroup END

" diff options

" reverting wrap to its global value when in diff mode
augroup DiffWrapAutoGroup
    autocmd!
    autocmd FilterWritePre * if &diff | setlocal wrap< | endif
augroup END

augroup GitCommit
    autocmd!
    autocmd BufWinEnter COMMIT_EDITMSG startinsert
augroup END

augroup SessionLoadPostAutoGroup
    autocmd!
    " Wiping empty buffers created by restoring sessions
    autocmd SessionLoadPost * silent call buffer#BWipeNotReadableForce()
augroup END

augroup TermAutoGroup
    autocmd!
    " To enter Terminal-mode automatically:
    autocmd VimEnter * autocmd TermAutoGroup TermOpen * startinsert
    autocmd TermEnter * set nonumber
augroup END
if v:vim_did_enter
    doautocmd TermAutoGroup VimEnter
endif

augroup TabClosedAutoGroup
    autocmd!
    " Returning to previous tab instead of the next
    autocmd TabClosed * if expand("<afile>") > 1 && expand("<afile>") <= tabpagenr("$") |
                \     tabprevious |
                \ endif
augroup END

augroup NodeJS
    autocmd!
    autocmd BufReadPost,VimEnter **/node_modules/* setlocal nomodifiable
augroup END

" }}}

" sourcing init.local.vim if it exists

let s:init_local = g:vim_dir . "/init.local.vim"
if filereadable(s:init_local)
  execute "source " . s:init_local
endif

" Finish here if we haven't initialized the submodules

if glob(g:vim_dir."/pack/bundle/start/*/plugin") == ""
    finish
endif

" Subsection: package customisation {{{

" CamelCase

map <silent> <Leader>w <Plug>CamelCaseMotion_w
map <silent> <Leader>b <Plug>CamelCaseMotion_b
map <silent> <Leader>e <Plug>CamelCaseMotion_e
map <silent> <Leader>ge <Plug>CamelCaseMotion_ge

" ctrlp

if !executable("fzf")
    let s:ctrlp_cache_dir = g:vim_dir."/ctrlp_cache"
    exe "let s:has_ctrlp_cache_dir = isdirectory('".s:ctrlp_cache_dir."')"
    if !s:has_ctrlp_cache_dir
        call mkdir(s:ctrlp_cache_dir)
    endif
    let g:ctrlp_cache_dir = s:ctrlp_cache_dir
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
    let g:ctrlp_map = "<f7>"
    let g:ctrlp_tabpage_position = "bc"
    let g:ctrlp_clear_cache_on_exit = 0
    nnoremap <F5> :CtrlPBuffer<cr>

    " Copied from the help file
    let g:ctrlp_prompt_mappings = {
                \ 'PrtSelectMove("j")':   ['<c-n>', '<down>'],
                \ 'PrtSelectMove("k")':   ['<c-p>', '<up>'],
                \ 'PrtHistory(-1)':       ['<c-j>'],
                \ 'PrtHistory(1)':        ['<c-k>'],
                \ }
    packadd! ctrlp.vim
endif

" vim-rzip

let g:rzipPlugin_extra_ext = "*.odt"

" paredit

let g:paredit_leader = '\'

" sneak

map f <Plug>Sneak_f
map F <Plug>Sneak_F
map t <Plug>Sneak_t
map T <Plug>Sneak_T

map <Space>f <Plug>Sneak_s
map <Space>F <Plug>Sneak_S

" scalpel

nmap <Leader>x <Plug>(Scalpel)

" delimitMate

augroup DelimitMatePackageGroup
    autocmd!
    autocmd FileType lisp,*clojure*,scheme,racket let b:loaded_delimitMate = 1
    " apache
    autocmd FileType apache let b:delimitMate_matchpairs = "(:),[:],{:},<:>"
augroup END

" vim-easy-align
" Start interactive EasyAlign in visual mode (e.g. vip<Plug>(EasyAlign))
xmap gy <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. <Plug>(EasyAlign)ip)
nmap gy <Plug>(EasyAlign)

" vim-quickhl

nmap <Space>m <Plug>(quickhl-manual-this)
xmap <Space>m <Plug>(quickhl-manual-this)
nmap <Space>M <Plug>(quickhl-manual-reset)
xmap <Space>M <Plug>(quickhl-manual-reset)

nmap <Space>w <Plug>(quickhl-manual-this-whole-word)
xmap <Space>w <Plug>(quickhl-manual-this-whole-word)

nmap <Space>c <Plug>(quickhl-manual-clear)
vmap <Space>c <Plug>(quickhl-manual-clear)

" vim-fugitive

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
if exists("*Clip")
    command! -nargs=0 FObject call Clip(FObject())
    command! -nargs=0 FPath call Clip(FPath())
else
    command! -nargs=0 FObject :let @"=FObject()
    command! -nargs=0 FPath :let @"=FPath()
endif

cnoreabbrev Gd Git difftool -y
cnoreabbrev Gl Git log
cnoreabbrev Glns Git log --name-status
cnoreabbrev Glo Git log --oneline
" To list branches of a specific remote: Git! ls-remote upstream
cnoreabbrev Gr Git! ls-remote

" dirvish

let g:loaded_netrwPlugin = 1
command! -nargs=? -complete=dir Explore Dirvish <args>

" reply.vim

command! -nargs=0 ReplFile call reply#command#send(join(getline(1,line("$")),"\n"),0,0)

" vim-ripgrep

" Search by exact word
cnoreabbrev Rw Rg -s '\b\b'<Left><Left><Left>

" }}}

" vim: fdm=marker
