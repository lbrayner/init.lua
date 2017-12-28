let s:has_windows = 0
if has('win32') || has('win64')
    let s:has_windows = 1
endif

set enc=utf-8

set nocompatible
syntax on

" set clipboard+=unnamedplus

set ttimeoutlen=0
set laststatus=2
set listchars=eol:¬,tab:»\ ,trail:·
set splitbelow
set splitright
set number
set relativenumber
set wildmenu
set breakindent
set linebreak
set autoindent
set hlsearch
set hidden
set nostartofline
set fileformats=unix,dos
set fileformat=unix
set backspace=2
set backspace=indent,eol,start
if s:has_windows
    set shellslash
endif
set incsearch
set nojoinspaces

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

if has('packages')
    if has('unix')
        set packpath+=~/.vim/pack/bundle
    endif
    if s:has_windows
        exec "set packpath+=".$HOME."/vimfiles/pack/bundle"
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

if has("unix")
    if !has("nvim")
        set dir=~/.vim/swap
    endif
endif

if s:has_windows
    let s:vim_dir = escape(expand('~'),' ') . '/vimfiles/swap//'
    let &dir=s:vim_dir
endif

let s:dictionaries = {
            \ 'en': 'c:\Users\leona\usr\share\dict\american-english-huge',
            \ 'br': 'c:\Users\leona\usr\share\dict\brazilian-utf8'
            \ }

function! s:SetDictionaryLanguage(global,language)
    if a:global
        let &dictionary = s:dictionaries[a:language]
        return
    endif
    let &l:dictionary = s:dictionaries[a:language]
endfunction

command! -nargs=1 SetDictionaryLanguage call s:SetDictionaryLanguage(0,<f-args>)
command! -nargs=1 SetGlobalDictionaryLanguage call s:SetDictionaryLanguage(1,<f-args>)

SetGlobalDictionaryLanguage en

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
nnoremap <leader><F6> :w!<CR>
nnoremap <leader>W :bw<CR>
nnoremap <leader>Q :q<CR>
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

nnoremap <silent> <leader>B :b#<CR>

" merge

command! JumpToNextMergeConflictLeft   :keepp keepj ?^<<<<<<<
command! JumpToNextMergeConflictMiddle :keepp /^=======
command! JumpToNextMergeConflictRight  :keepp keepj /^>>>>>>>

nnoremap <silent> <leader>cr :JumpToNextMergeConflictRight<cr>
nnoremap <silent> <leader>cm :JumpToNextMergeConflictMiddle<cr>
nnoremap <silent> <leader>cl :JumpToNextMergeConflictLeft<cr>

"help buffers

augroup HelpAutoGroup
    autocmd!
    " autocmd FileType help,eclimhelp nnoremap <silent> <buffer> <nowait> q :q<cr>
    autocmd FileType help,eclimhelp au BufEnter <buffer> setlocal relativenumber
augroup END

augroup SvnFtGroup
    autocmd!
    autocmd BufEnter *.svn set ft=svn
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
command! RelativePath :let @*=@%
command! Bwp :bp | bw #
command! BwpForce :bp | bw! #

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

set textwidth=80

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
endif

if !has('packages')
    finish
endif

" Plugin customisation

" loupe

let g:LoupeCenterResults=0
nmap <f2> <Plug>(LoupeClearHighlight)

" Eclim

let g:EclimHighlightError = "Error"
let g:EclimHighlightWarning = "Ignore"
" let g:EclimHighlightInfo = "Type"

let g:EclimMakeLCD = 1
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
let g:ctrlp_reuse_window = 'netrw\|help'
let s:ctrlp_custom_ignore = {
            \ 'file': '\v\.o$|\.exe$|\.lnk$|\.bak$|\.swp$|\.class$|\.jasper$'
            \               . '|\.r[0-9]+$|\.mine$',
            \ 'dir': '\C\V' . escape(expand('~'),' \') . '\$\|'
            \               . '\v[\/](classes|target|build|test-classes|dumps)$'
            \ }
let g:ctrlp_working_path_mode = ''

command! CtrlpCustomIgnoreDefault :let g:ctrlp_custom_ignore = s:ctrlp_custom_ignore

let g:ctrlp_custom_ignore = deepcopy(s:ctrlp_custom_ignore)

let g:ctrlp_switch_buffer = 't'
let g:ctrlp_map = '<f7>'
nnoremap <silent> <F5> :CtrlPBuffer<cr>
nnoremap <leader><F7> :CtrlPClearAllCaches<cr>


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

" " fireplace
" augroup FireplaceAutoGroup
" autocmd FileType clojure nmap <buffer> cç <Plug>FireplacePrompt<c-f>k
" autocmd FileType clojure
"             \ nmap <buffer> cÇ <Plug>FireplacePrompt<up><cr>
" augroup END

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

" ferret
let g:FerretExecutable="ag"

" scalpel
nmap <Leader>x <Plug>(Scalpel)
