let s:has_windows = 0
if has('win32') || has('win64')
    let s:has_windows = 1
endif

set enc=utf-8

set nocompatible
syntax on

set ttimeoutlen=0
set laststatus=2
set listchars=eol:¬,tab:»\ ,trail:·
set splitbelow
set splitright
set number
set relativenumber
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
if s:has_windows
    set shellslash
endif
set incsearch
set nojoinspaces
set ignorecase
set smartcase

let s:ssh_client = 0

if $SSH_CLIENT != ''
    let s:ssh_client = 1
endif

if has("nvim")
    if s:ssh_client
        set mouse=
    else
        set mouse=a
    endif
endif

let s:vim_dir = $HOME . "/.vim"

if s:has_windows
    let s:vim_dir = $HOME . "/vimfiles"
endif

if has("path_extra")
    set fileignorecase
endif

if has('packages')
    if has('unix')
        set packpath+=~/.vim/pack/bundle
    endif
    if s:has_windows
        set packpath+=$HOME/vimfiles/pack/bundle
    endif
    if !has("nvim")
        packadd matchit
    endif
endif

if $SHELL =~# 'sh'
    set noshelltemp
endif

if s:has_windows
    set grepprg=grep.exe
endif

" setting dir

if !has("nvim")
    let s:swap_dir = s:vim_dir."/swap"
    exe "let s:has_swap_dir = isdirectory('".s:swap_dir."')"
    if !s:has_swap_dir
        call mkdir(s:swap_dir)
    endif
    let &dir=s:swap_dir."//"
endif

nmap ç :
vmap ç :
nmap Ç :<up><cr>
vmap Ç :<up><cr>
nnoremap ¬ ^
nnoremap qç q:
vnoremap qç q:
vnoremap ¬ ^
vnoremap <F3> :w !$SHELL<CR>
vnoremap <F4> yy:@"<CR>

nnoremap <f1> :vert h<space>
vnoremap <f1> <esc>:vert h

nnoremap <silent> <Esc><Esc> <Esc>:on<CR>

" clear search highlights

function! s:HighlightOverLength()
    if ! exists("s:OverLength")
        let s:OverLength = 90
    endif
    if ! exists("w:HighlightOverLengthFlag")
        let w:HighlightOverLengthFlag = 1
    endif
    if w:HighlightOverLengthFlag
        highlight OverLength ctermbg=red ctermfg=white guibg=#592929
        exec 'match OverLength /\%' . s:OverLength . 'v.\+/'
        echo "Overlength highlighted."
    else
        exec "match"
        echo "Overlength highlight cleared."
    endif
    let w:HighlightOverLengthFlag = ! w:HighlightOverLengthFlag
endfunction

nnoremap <silent> <f2> :set invhlsearch hlsearch?<cr>
nnoremap <silent> <leader><f2> :call <SID>HighlightOverLength()<cr>

vnoremap <silent> <leader>* y:exec 'let @/="\\V" . @"'<cr>

vnoremap <C-H> <esc><C-W>h
vnoremap <C-J> <esc><C-W>j
vnoremap <C-K> <esc><C-W>k
vnoremap <C-L> <esc><C-W>l

nnoremap <leader>v <C-w>v
nnoremap <leader>h <C-w>s

nnoremap <leader>i :set invpaste paste?<CR>

nnoremap <silent> <leader>yy "+yy:let @*=@"<cr>
nnoremap <silent> <leader>p "+p
vnoremap <silent> <leader>p "+p
vnoremap <silent> <leader>y "+y:let @*=@"<cr>


nnoremap <leader>A :res +10<cr>
nnoremap <leader>S :res -10<cr>

nnoremap <silent> <leader>R :set relativenumber!<cr>

nnoremap <C-H> <C-W><C-H>
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>

nnoremap <silent> <leader><F3> :.!<C-R>=getline('.')<CR><cr>

if s:has_windows
    function! s:FilterLine()
        let line = getline('.')
        let temp = tempname()
        exe 'sil! !'.escape(line,&shellxescape).' > '.temp.' 2>&1'
        if v:shell_error
            exe 'throw "'.escape(readfile(temp)[0],'"').'"'
        endif
        exe "sil! read ".fnameescape(temp)
        exe "sil call delete ('".temp."')"
    endfunction
    nnoremap <silent> <leader><F3> :call <SID>FilterLine()<cr>
endif


nnoremap <F3> :.w !$SHELL<CR>
nnoremap <F4> :execute getline(".")<CR>
nnoremap <leader><F5> :ls<CR>:buffer<Space>
nnoremap <F6> :w<CR>
nnoremap <leader><F7> :find<space>
nnoremap <leader><F6> :w!<CR>
nnoremap <leader>W :bw<CR>
nnoremap <silent> <F12>  :setlocal list!<CR>
nnoremap <leader>\| :setlocal wrap! wrap?<CR>
nnoremap <silent> <leader>N :setlocal number!<CR>
nnoremap <leader>L :set linebreak! linebreak?<CR>
vnoremap . :normal .
inoremap <S-Tab> <C-V><Tab>

inoremap <F6> <esc>:w<CR>

nnoremap <silent> <F9> :q<cr>
nnoremap <silent> <leader><F9> :bw<cr>

" quickfix and locallist

nnoremap <silent> <leader>l :lopen<CR>
nnoremap <silent> <leader>q :copen<CR>
nnoremap <silent> <leader>Q :cclose<CR>

nnoremap <silent> <leader>B :b#<CR>

" merge

command! JumpToNextMergeConflictLeft   :keepp keepj ?^<<<<<<<
command! JumpToNextMergeConflictMiddle :keepp /^=======
command! JumpToNextMergeConflictRight  :keepp keepj /^>>>>>>>

nnoremap <silent> <leader>cr :JumpToNextMergeConflictRight<cr>
nnoremap <silent> <leader>cm :JumpToNextMergeConflictMiddle<cr>
nnoremap <silent> <leader>cl :JumpToNextMergeConflictLeft<cr>

" search / pattern

" force case sensitivity for *-search
nnoremap <Plug>CaseSensitiveStar /\C\V\<<c-r>=expand("<cword>")<cr>\><cr>
nmap <kmultiply> <Plug>CaseSensitiveStar
nmap * <Plug>CaseSensitiveStar

"help buffers

augroup HelpAutoGroup
    autocmd!
    autocmd FileType help,eclimhelp au BufEnter <buffer> setlocal relativenumber
augroup END

" svn commit files

augroup SvnFtGroup
    autocmd!
    autocmd BufEnter *.svn set ft=svn
augroup END

" infercase

augroup InferCaseGroup
    autocmd!
    autocmd FileType gitcommit,text,svn setlocal ignorecase infercase
augroup END

"show existing tab with 4 spaces width
set tabstop=4
" when indenting with '>', use 4 spaces width
set shiftwidth=4
set expandtab

" XML

let s:LargeXmlFile = 1024 * 512
augroup XmlAutoGroup
    autocmd BufRead * if &filetype ==# "xml" | let f=expand("<afile>")
            \| if getfsize(f) > s:LargeXmlFile | setlocal syntax=unknown | endif | endif
augroup END

" Copy

command! CopyFullPath :let @*=expand('%:p') | let @+=@* | let @"=@*
command! CopyPath :let @*=expand('%') | let @+=@* | let @"=@*
command! CopyName :let @*=expand('%:t') | let @+=@* | let @"=@*

augroup RelativeNumberAutoGroup
    autocmd InsertEnter * :set norelativenumber
    autocmd InsertLeave * :set relativenumber
augroup END

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

" text format options

augroup TextFormatAutoGroup
    au!
    autocmd FileType text,svn setlocal textwidth=80
augroup END

" diff options

augroup DiffWrapAutoGroup
    autocmd FilterWritePre * if &diff | setlocal wrap< | endif
augroup END

function! g:IncrementVariable(var)
    exe "let ".a:var." = ".a:var." + 1"
    exe "let to_return = ".a:var
    return to_return
endfunction

if has("gui_running") || has("nvim")
    " For Emacs-style editing on the command-line >
    " start of line
    cnoremap <C-A> <Home>
    " back one character
    cnoremap <C-B> <Left>
    " delete character under cursor
    cnoremap <C-D> <Del>
    " end of line
    cnoremap <C-E> <End>
    " forward one character
    cnoremap <C-F> <Right>
    " recall newer command-line
    cnoremap <C-N> <Down>
    " recall previous (older) command-line
    cnoremap <C-P> <Up>
    " back one word
    cnoremap <M-b> <S-Left>
    " forward one word
    cnoremap <M-f> <S-Right>
    " cancel
    cnoremap <C-G> <C-C>
    " open the command line buffer
    cnoremap <C-Z> <C-F>
endif

" inserting the current line
cnoremap <c-r><c-l> <c-r>=line(".")<cr>

" emacs c-k behaviour
inoremap <c-k> <c-o>D
cnoremap <c-k> <c-f>D<c-c><c-c>:<up>
" remapping digraph
inoremap <c-s> <c-k>
cnoremap <c-s> <c-k>

if !has('packages')
    finish
endif

" Plugin customisation

" Eclim

let g:EclimHighlightError = "Error"
let g:EclimHighlightWarning = "Ignore"

let g:EclimXmlValidate=0
let g:EclimXsdValidate=0
let g:EclimDtdValidate=0

augroup EclimAutoGroup
    autocmd FileType java nnoremap <buffer> <F11> :JavaCorrect<CR>
    autocmd FileType java nnoremap <buffer> <leader><F11> :JavaSearchContext<CR>
augroup END

let g:EclimMakeLCD = 1
let g:EclimJavaSearchSingleResult = 'edit'

" CamelCase

map <silent> <leader>w <Plug>CamelCaseMotion_w
map <silent> <leader>b <Plug>CamelCaseMotion_b
map <silent> <leader>e <Plug>CamelCaseMotion_e
map <silent> <leader>ge <Plug>CamelCaseMotion_ge

" ctrlp
let g:ctrlp_working_path_mode = ''
let g:ctrlp_reuse_window = 'netrw\|help'
let s:ctrlp_custom_ignore = {
            \ 'file': '\v\.o$|\.exe$|\.lnk$|\.bak$|\.swp$|\.class$|\.jasper$'
            \               . '|\.r[0-9]+$|\.mine$',
            \ 'dir': '\C\V' . escape(expand('~'),' \') . '\$\|'
            \               . '\v[\/](classes|target|build|test-classes|dumps)$'
            \ }

let g:ctrlp_custom_ignore = deepcopy(s:ctrlp_custom_ignore)

let g:ctrlp_switch_buffer = 't'
let g:ctrlp_map = '<f7>'
let g:ctrlp_tabpage_position = 'bc'
let g:ctrlp_match_window = 'bottom,order:ttb,min:1,max:10,results:10'
let g:ctrlp_clear_cache_on_exit = 0
nnoremap <silent> <F5> :CtrlPBuffer<cr>

" vim-rzip
let g:zipPlugin_extra_ext = '*.odt'

" solarized

let s:enable_solarized = 1

if !has("nvim") && !has("gui_running") && s:ssh_client
    let s:enable_solarized = 0
endif

if has("win32unix")
    let s:enable_solarized = 0
endif

if s:enable_solarized
    set cursorline
    let g:solarized_italic = 1
    colorscheme solarized
    set background=dark
endif

" netrw
let g:netrw_bufsettings = 'noma nomod number relativenumber nobl wrap ro hidden'
let g:netrw_liststyle = 3

" paredit
let g:paredit_leader = '\'

" syntastic
" autocmd FileType java SyntasticToggleMode
let g:syntastic_mode_map = { 'mode': 'passive', 'active_filetypes': []}
let g:syntastic_java_javac_config_file_enabled = 1

" sneak
map f <Plug>Sneak_f
map F <Plug>Sneak_F
map t <Plug>Sneak_t
map T <Plug>Sneak_T

map x <Plug>Sneak_s
map X <Plug>Sneak_S

" scalpel
nmap <Leader>x <Plug>(Scalpel)

" Glaive
augroup GlaiveInstallGroup
    autocmd!
    autocmd VimEnter * call glaive#Install()
augroup END

" statusline

if v:vim_did_enter
    call MyVimStatusLine#initialize()
else
    au VimEnter * call MyVimStatusLine#initialize()
endif

" sourcing a init.local.vim if it exists

let s:init_local = s:vim_dir . "/init.local.vim"
if filereadable(s:init_local)
  execute 'source ' . s:init_local
endif
