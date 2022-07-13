" inferring where we are

if $XDG_CONFIG_HOME == ""
    let $XDG_CONFIG_HOME = '~/.config'
    if has("win32") || has("win64")
        let $XDG_CONFIG_HOME = '~/AppData/Local'
    endif
    let $XDG_CONFIG_HOME = fnamemodify($XDG_CONFIG_HOME,":p")
endif

if !exists("g:vim_dir") || g:vim_dir == ""
    let g:vim_dir = $HOME . "/.vim"

    if has("win32") || has("win64")
        let g:vim_dir = $USERPROFILE . "/vimfiles"
    endif

    if has("nvim")
        let g:vim_dir = $XDG_CONFIG_HOME . "/nvim"
    endif

    if $MYVIMRC == ""
        let g:vim_dir = expand("<sfile>:p:h")
    endif
endif

" Subsection: settings {{{

set encoding=utf-8
filetype plugin indent on
set nocompatible
syntax on

if $TERM == "st-256color"
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
    set t_Co=256
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
if has("win32") || has("win64")
    if isdirectory('c:/cygwin64/bin')
        let $PATH .= ';c:\cygwin64\bin'
    endif
    if executable("bash.exe")
        set shell=bash.exe
        set noshelltemp
    endif
    if executable("grep.exe")
        set grepprg=grep.exe
    endif
    set shellslash
endif
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

" setting dir

if !has("nvim")
    let s:swap_dir = g:vim_dir."/swap"
    exe "let s:has_swap_dir = isdirectory('".s:swap_dir."')"
    if !s:has_swap_dir
        call mkdir(s:swap_dir)
    endif
    let &dir=s:swap_dir."//"
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

" setting undodir

if !has("nvim")
    let s:undo_dir = g:vim_dir."/undo"
    exe "let s:has_undo_dir = isdirectory('".s:undo_dir."')"
    if !s:has_undo_dir
        call mkdir(s:undo_dir)
    endif
    let &undodir=s:undo_dir."/"
endif

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
noremap <Plug>(Cmd) :
nmap ç <Plug>(Cmd)
vmap ç <Plug>(Cmd)
nmap Ç :<Up><CR>
vmap Ç :<Up><CR>
nnoremap ¬ ^
nnoremap qç q:
vnoremap qç q:
vnoremap ¬ ^

nnoremap <silent> <Esc><Esc> <Esc>:only<CR>

" clear search highlights

nnoremap <silent> <f2> :set invhlsearch hlsearch?<cr>

" easier window switching
nnoremap <C-H> <C-W>h
nnoremap <C-J> <C-W>j
nnoremap <C-K> <C-W>k
nnoremap <C-L> <C-W>l

vnoremap <C-H> <esc><C-W>h
vnoremap <C-J> <esc><C-W>j
vnoremap <C-K> <esc><C-W>k
vnoremap <C-L> <esc><C-W>l

" splits
nnoremap <leader>v <C-w>v
nnoremap <leader>h <C-w>s

nnoremap <leader>i :set invpaste paste?<CR>

nnoremap <leader><F5> :ls<CR>:buffer<Space>
nnoremap <F6> :w<CR>
inoremap <F6> <esc>:w<CR>
vnoremap <F6> <esc>:w<CR>
nnoremap <leader><F6> :w!<CR>
nnoremap <silent> <F12>  :setlocal list!<CR>
inoremap <silent> <F12>  <C-O>:setlocal list!<CR>
vnoremap . :normal .

" previous buffer
nnoremap <silent> <space>b :b#<CR>

" quickfix and locallist

nnoremap <silent> <leader>l :botright lopen<CR>
nnoremap <silent> <leader>q :botright copen<CR>

" force case sensitivity for *-search
nnoremap <Plug>CaseSensitiveStar /\C\V\<<c-r>=expand("<cword>")<cr>\><cr>
nmap <kMultiply> <Plug>CaseSensitiveStar
nmap * <Plug>CaseSensitiveStar

" sometimes you want to search with no noincsearch set

function! s:NoIncSearchStart()
    set updatetime=1
    let s:incsearch = &incsearch
    set noincsearch
endfunction

function! s:NoIncSearchEnd()
    if !exists("s:incsearch")
        return
    endif
    let &incsearch = s:incsearch
endfunction

augroup NoIncSearchCursorHoldAutoGroup
    autocmd!
    autocmd CursorHold * call s:NoIncSearchEnd()
augroup END

nnoremap <kDivide> :call <SID>NoIncSearchStart()<cr>/
nnoremap <leader>/ :call <SID>NoIncSearchStart()<cr>/

" neovim terminal
if has("nvim")
    tnoremap <A-h> <C-\><C-n><C-w>h
    tnoremap <A-j> <C-\><C-n><C-w>j
    tnoremap <A-k> <C-\><C-n><C-w>k
    tnoremap <A-l> <C-\><C-n><C-w>l
    tnoremap <leader><Esc> <C-\><C-n>
    nnoremap <A-h> <C-w>h
    nnoremap <A-j> <C-w>j
    nnoremap <A-k> <C-w>k
    nnoremap <A-l> <C-w>l
endif

" Emacs-style editing in command-line mode and insert mode
if has("gui_running") || has("nvim")
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
endif

" inserting the current line
cnoremap <c-r><c-l> <c-r>=getline(".")<cr>
" inserting the current line number
cnoremap <c-r><c-n> <c-r>=line(".")<cr>

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

nnoremap <leader>do :diffoff!<cr>
nnoremap <leader>di :call <SID>ToggleIWhite()<cr>

" Unclutter, i.e. close certain special windows

nnoremap <F9> :Unclutter<cr>

augroup CmdwinClose
    autocmd!
    autocmd CmdwinEnter * nnoremap <buffer> <F9> :q<cr>
augroup END

" Insert timestamps

imap <F3> <C-R>=strftime("%Y-%m-%d %a %0H:%M")<CR>

" tabs

if exists("*gettabinfo")
    nmap <F8> <Plug>GoToTab
else
    nmap <F8> :tabs<cr>
endif

" }}}

" Subsection: functions & commands

" Increments a numeric variable
function! g:IncrementVariable(var)
    exe "let ".a:var." = ".a:var." + 1"
    exe "let to_return = ".a:var
    return to_return
endfunction

" Clear the Quickfix List

function s:ClearQuickfixList()
  call setqflist([])
endfunction

command! ClearQuickfixList call s:ClearQuickfixList()

function! Path()
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
        if stridx(getreg('"'),"\n") < 0 && len(getreg('"')) <= &columns*0.9
            echo @"
        elseif len(getreg('"',1,1)) > 2
            echo len(getreg('"',1,1)) . " lines clipped"
        endif
    endfunction

    " Copies arg to the system's clipboard
    command! -nargs=? Clip call Clip(<f-args>)

    nnoremap <leader>c :Clip<cr>
    vnoremap <leader>c y:Clip<cr>

    nnoremap <leader>p "+p
    vnoremap <leader>p "+p

    command! Path call Clip(Path())
    command! FullPath call Clip(FullPath())
    command! Name call Clip(Name())
    command! Cwd call Clip(Cwd())
else
    command! Path :let @"=Path()
    command! FullPath :let @"=FullPath()
    command! Name :let @"=Name()
    command! Cwd :let @"=Cwd()
endif

command! -bar AllLowercase call util#PreserveViewPort('keeppatterns %s/.*/\L&/g')

command! -nargs=0 -bar -range=% DeleteTrailingWhitespace
            \ call util#PreserveViewPort("keeppatterns ".<line1>.",".<line2>.'s/\s\+$//e')

cnoreabbrev D DeleteTrailingWhitespace

command! Lcd lcd %

cnoreabbrev L Lcd

command! -nargs=0 -bar -range=% Capitalize
            \ call util#PreserveViewPort(
            \     "keeppatterns ".<line1>.",".<line2>.'s/\<./\u&/ge')

command! -nargs=1 FileSearch call quickfix#ilist_search(0,<f-args>,1,1)

function! s:NumberToggle()
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

command! -nargs=0 NumberToggle call s:NumberToggle()

" https://vi.stackexchange.com/a/36414
function! s:Source(line_start,line_end)
    let tempfile = tempname()
    sil exe a:line_start.",".a:line_end."write ".fnameescape(tempfile)
    exe "source ".fnameescape(tempfile)
    call delete(tempfile)
    if a:line_start == a:line_end
        echom "Sourced line ".a:line_start."."
        return
    endif
    echom "Sourced lines ".a:line_start." to ".a:line_end."."
endfunction

command! -nargs=0 -range Source call s:Source(<line1>,<line2>)

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

if executable('svn')
    command! Scursor call subversion#SVNDiffCursor()
    command! Sthis call subversion#SVNDiffThis()
    command! Sdiff call subversion#SVNDiffContextual()
endif

function! s:Synstack()
    echo map(synstack(line("."), col(".")),"synIDattr(v:val, 'name')")
endfunction

" Human-readable stack of syntax items
command! -nargs=0 -range Synstack call s:Synstack()

" Subsection: autocommands {{{

" Restores 'updatetime' to the default value
augroup Updatetime
    autocmd!
    autocmd CursorHold * set updatetime=4000
augroup END

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

function! s:Aesthetics()
    if &ft =~ "netrw"
        return
    endif
    " setting nonumber if length of line count is greater than 3
    if len(line("$"))>3
        setlocal nonumber
    endif
endfun

augroup AestheticsAutoGroup
    autocmd!
    autocmd BufRead * call s:Aesthetics()
augroup END

"help buffers

augroup HelpAutoGroup
    autocmd!
    autocmd FileType help,eclimhelp autocmd BufEnter <buffer> set relativenumber
augroup END

" comment string

augroup PoundComment
    autocmd!
    autocmd FileType apache,crontab,debsources,desktop,fstab,samba
                \ autocmd BufEnter <buffer> let &l:commentstring = "# %s"
augroup END

" svn commit files

augroup SvnFtGroup
    autocmd!
    autocmd BufEnter *.svn set ft=svn
augroup END

augroup XmlFtGroup
    autocmd!
    autocmd BufEnter *.wsdl set ft=xml " Web Services Description Language
augroup END

" vidir

augroup VidirGroup
    autocmd!
    autocmd BufEnter /tmp/dir*
                \ if argc() == 1 && argv(0) =~# '^/tmp/dir' |
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

" norelativenumber in non focused windows
augroup RelativeNumberAutoGroup
    autocmd!
    autocmd VimEnter * autocmd RelativeNumberAutoGroup
                \ WinLeave * if &number |
                \     set norelativenumber |
                \ endif
    autocmd VimEnter * autocmd RelativeNumberAutoGroup
                \ BufWinEnter,WinEnter * set relativenumber
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

" VimEnter

augroup VimEnterAutoGroup
    autocmd!
    " v:vim_did_enter not available before 8.0
    autocmd VimEnter * let g:vim_did_enter = 1
augroup END

augroup SessionLoadPostAutoGroup
    autocmd!
    " Wiping empty buffers created by restoring sessions
    autocmd SessionLoadPost * silent BWipeNotReadable
augroup END

if has("nvim")
    augroup TermAutoGroup
        autocmd!
        " To enter Terminal-mode automatically:
        autocmd VimEnter * autocmd TermAutoGroup TermOpen * startinsert
        autocmd TermEnter * set nonumber
    augroup END
endif

" }}}

" sourcing init.local.vim if it exists

let s:init_local = g:vim_dir . "/init.local.vim"
if filereadable(s:init_local)
  execute "source " . s:init_local
endif

" sourcing ginit.vim if it exists

if has("gui_running")
    if $MYGVIMRC == ""
        let s:ginit = g:vim_dir . "/ginit.vim"
        if filereadable(s:ginit)
          execute "source " . s:ginit
        endif
    endif
endif

" sourcing ginit.local.vim if it exists

if has("gui_running")
    let s:ginit_local = g:vim_dir . "/ginit.local.vim"
    if filereadable(s:ginit_local)
      execute "source " . s:ginit_local
    endif
endif

" Subsection: plugins {{{

" netrw

let g:netrw_bufsettings = "noma nomod number relativenumber nobl wrap ro hidden"
let g:netrw_liststyle = 3

" Eclim

if !has("win32unix")
    let g:EclimLogLevel = "info"

    let g:EclimHighlightError = "Error"
    let g:EclimHighlightWarning = "Comment"

    let g:EclimXmlValidate=0
    let g:EclimXsdValidate=0
    let g:EclimDtdValidate=0

    let g:EclimMakeLCD = 1
    let g:EclimJavaSearchSingleResult = "edit"
endif

" }}}

" Subsection: packages

if !has("packages")
    finish
endif

if !has("nvim")
    packadd matchit
endif

" Finish here if we haven't initialized the submodules

let g:initialized_packages = 1

if glob(g:vim_dir.'/pack/bundle/start/*/plugin') == ""
    let g:initialized_packages = 0
    finish
endif

" Subsection: package customisation {{{

" CamelCase

map <silent> <leader>w <Plug>CamelCaseMotion_w
map <silent> <leader>b <Plug>CamelCaseMotion_b
map <silent> <leader>e <Plug>CamelCaseMotion_e
map <silent> <leader>ge <Plug>CamelCaseMotion_ge

" ctrlp

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
            \ "dir": '\C\V' . escape(expand('~'),' \') . '\$' . '\|ctrlp_cache\$'
            \ }

let g:ctrlp_custom_ignore = {
            \ "func": "extensions#ctrlp#ignore"
            \ }

let g:ctrlp_switch_buffer = "t"
let g:ctrlp_map = "<f7>"
let g:ctrlp_tabpage_position = "bc"
let g:ctrlp_clear_cache_on_exit = 0
nnoremap <F5> :CtrlPBuffer<cr>

let g:ctrlp_prompt_mappings = {
    \ 'PrtSelectMove("j")':   ['<c-n>', '<down>'],
    \ 'PrtSelectMove("k")':   ['<c-p>', '<up>'],
    \ 'PrtHistory(-1)':       ['<c-j>'],
    \ 'PrtHistory(1)':        ['<c-k>'],
    \ }

" fzf.vim

if has("unix") && !has("win32unix") && executable("fzf")
    if isdirectory($HOME . "/.fzf")
        set rtp+=~/.fzf
    elseif isdirectory("/usr/share/doc/fzf/examples") " Linux
        set rtp+=/usr/share/doc/fzf/examples
    endif

    let g:fzf_buffers_jump = 1

    " eclim might shadow this command
    command! -bar -bang -nargs=? -complete=buffer Buffers call fzf#vim#buffers(<q-args>,
                \ fzf#vim#with_preview({ "placeholder": "{1}" }), <bang>0)

    function! s:FZF_Command(command)
        if !exists(":FZF")
            echomsg "FZF is not defined. " .
                        \ "Please add the fzf package to the runtimepath (fzf ≠ fzf.vim)."
            return
        endif
        " In case the file is opened in a new tab with Ctrl-T, the new window
        " will inherit &cursorline from the FZF popup, which is always false
        let cul = &cursorline
        exe a:command
        let &cursorline = cul
    endfunction

    nnoremap <silent> <F5> :call <SID>FZF_Command("Buffers")<cr>
    nnoremap <silent> <F7> :call <SID>FZF_Command("FZF")<cr>

    unlet g:ctrlp_map " else the F7 mapping is going to be overridden by Ctrlp

    if executable("dfzf")
        function! s:dfzf_clear_cache()
            let fzf_command=$FZF_DEFAULT_COMMAND
            let $FZF_DEFAULT_COMMAND="dfzf -C"
            call s:FZF_Command("FZF")
            let $FZF_DEFAULT_COMMAND=fzf_command
        endfunction

        let $FZF_DEFAULT_COMMAND="dfzf"
        nnoremap <silent> <leader><f7> :call <SID>dfzf_clear_cache()<cr>
        if !executable("ag") && executable("ddfzf")
            let $DFZF_DEFAULT_COMMAND="ddfzf"
        endif
    endif
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

execute 'nmap <Leader>x <Plug>(Cmd)' .
      \ 'Scalpel' .
      \ "/\\v<<C-R>=expand('<cword>')<CR>>//<Left>"

" supertab

let g:SuperTabCtrlXCtrlPCtrlNSearchPlaces = 1

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

" vim-DetectSpellLang

" disabled by default
if !exists("g:guesslang_disable")
    let g:guesslang_disable = 1
endif
let g:guesslang_langs = [ "en", "pt" ]

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

command! -bar -bang -nargs=* -complete=customlist,fugitive#EditComplete Gdiffsplit
            \ exe fugitive#Diffsplit(1, <bang>0, "<mods>", <q-args>, [<f-args>])

cnoreabbrev Gd Git difftool -y
cnoreabbrev Gl Git log
cnoreabbrev Glns Git log --name-status
" To list branches of a specific remote: Git! ls-remote --heads upstream
cnoreabbrev Gh Git! ls-remote --heads

" Tagbar

command! Tbar TagbarToggle

" dirvish

let g:loaded_netrwPlugin = 1
command! -nargs=? -complete=dir Explore Dirvish <args>

" vim-diminactive

if !has("nvim")
    packadd vim-diminactive
endif

" nvim-lspconfig

if has("nvim")
    packadd nvim-lspconfig
endif

" }}}

" vim: fdm=marker
