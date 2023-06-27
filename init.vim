" inferring where we are

if !exists("g:vim_dir") || g:vim_dir == ""
    let g:vim_dir = stdpath("config")

    if $MYVIMRC == ""
        let g:vim_dir = expand("<sfile>:p:h")
    endif
endif

" Subsection: settings {{{

filetype plugin indent on

if $TERM == "foot" || stridx($TERM, "256color") >= 0
    set termguicolors
endif

set listchars=eol:¬,tab:»\ ,trail:·
set splitbelow
set splitright
set number
set relativenumber
set switchbuf=usetab,uselast
set wildmode=longest:full
set wildmenu
set breakindent
set linebreak
set fileformats=unix,dos
set fileformat=unix
set backspace=indent,eol,start
set ignorecase
set smartcase
set noruler
set lazyredraw
set title
set noshowmode
exe "set cedit=\<C-X>"

"show existing tab with 4 spaces width
set tabstop=4
" when indenting with '>', use 4 spaces width
set shiftwidth=4
set expandtab

" are we using ssh?
let g:ssh_client = 0

if $SSH_CLIENT != ""
    let g:ssh_client = 1
endif

" mouse selection yanks to the system clipboard when using ssh
if g:ssh_client
    set mouse=
endif

" So that watchprocesses work as expected
set backupcopy=yes

" From tpope's vim-sensible
if &synmaxcol == 3000
  " Lowering this improves performance in files with long lines.
  set synmaxcol=500
endif

" }}}

" Subsection: mappings — pt-BR keyboard {{{1

" disable Ex mode mapping
nmap Q <Nop>

" cedilla is right where : is on an en-US keyboard
nnoremap ç :
vnoremap ç :
nnoremap Ç :<Up><CR>
vnoremap Ç :<Up><CR>
nnoremap ¬ ^
nnoremap qç q:
vnoremap qç q:
vnoremap ¬ ^

" make the current window the only one on the screen
nnoremap <Space>o <Cmd>only<CR>
" alternate file
nnoremap <Space>a <Cmd>b#<CR>

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

" buffer navigation (these mappings are going to be overridden by packages)
if !v:vim_did_enter
    nnoremap <F5> <Cmd>ls<CR><Cmd>buffer<Space>
    nnoremap <F8> <Cmd>tabs<CR>
endif

" write
nnoremap <F6> <Cmd>w<CR>
inoremap <F6> <Esc><Cmd>w<CR>
vnoremap <F6> <Esc><Cmd>w<CR>
nnoremap <Leader><F6> <Cmd>w!<CR>

" list mode
nnoremap <silent> <F12> <Cmd>setlocal list!<CR>
inoremap <silent> <F12> <Cmd>setlocal list!<CR>

" quickfix and locallist
nnoremap <silent> <Space>l <Cmd>lopen<CR>
nnoremap <silent> <Space>q <Cmd>botright copen<CR>

" force case sensitivity for *-search
nnoremap * /\C\V\<<C-R><C-W>\><CR>

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

" Search selected file path: based on Nvim builtin vmap *
vnoremap <Leader>8 y/\V<C-R>=escape("<C-R>"", "/")<CR><CR>

" Command line

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

" Insert timestamps
imap <F3> <C-R>=strftime("%Y-%m-%d %a %0H:%M")<CR>

" Rename word
nnoremap <Leader>x :%s/\C\V\<<C-R><C-W>\>//gc<Left><Left><Left>
" Rename visual selection
vnoremap <Leader>x y:%s/\C\V<C-R>"//gc<Left><Left><Left>

" }}}

" Subsection: functions & commands

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

function! s:Synstack()
    echo map(synstack(line("."), col(".")),"synIDattr(v:val, 'name')")
endfunction

" Ripgrep

set grepprg=rg\ --vimgrep
let &grepformat = "%f:%l:%c:%m"
let &shellpipe="&>"

function! s:Rg(txt, ...)
    try
        call ripgrep#rg(a:txt)
        if len(getqflist())
            botright copen
        else
            cclose
            echom "No match found for " . a:txt
        endif
    catch /^Rg:/
        cclose
        echoe v:exception
    catch
        cclose
        echom "Error searching for " . a:txt . ". Unmatched quotes? Check your command."
    endtry
endfunction

command! -nargs=* -complete=file Rg :call s:Rg(<q-args>)
cnoreabbrev Rb Rg -s '\b''''\b'<Left><Left><Left><Left><Left>
cnoreabbrev Rw Rg -s '\b''<C-R><C-W>''\b'

" Human-readable stack of syntax items
command! -nargs=0 -range Synstack call s:Synstack()

" Subsection: autocmds {{{

augroup CmdWindow
    autocmd!
    autocmd CmdwinEnter * setlocal nospell
augroup END

function! s:InsertModeUndoPoint()
    if mode() != "i"
        return
    endif
    call feedkeys("\<C-G>u")
endfunction

augroup InsertModeUndoPoint
    autocmd!
    autocmd CursorHoldI * call s:InsertModeUndoPoint()
augroup END

function! s:DoAesthetics()
    if util#WindowIsFloating()
        return
    endif
    if &filetype ==# "fugitiveblame"
        return
    endif
    if !stridx(&syntax, "Neogit")
        return
    endif
    call s:Number()
endfun

augroup Aesthetics
    autocmd!
    autocmd BufWinEnter,BufWritePost * call s:DoAesthetics()
    " Aesthetics for help buffers
    autocmd FileType help autocmd! Aesthetics BufEnter <buffer> set relativenumber
augroup END
if v:vim_did_enter
    doautocmd Aesthetics VimEnter
endif

augroup SetFiletype
    autocmd!
    autocmd BufNewFile,BufRead .ignore set filetype=gitignore
    autocmd BufNewFile,BufRead *.redis set filetype=redis
    autocmd TermOpen * set filetype=terminal
    autocmd BufNewFile,BufRead /tmp/dir*
                \ if argc() == 1 && argv(0) =~# '^/tmp/dir\w\{5}$' |
                \     set filetype=vidir |
                \ endif
    autocmd BufNewFile,BufRead *.wsdl set filetype=xml " Web Services Description Language
augroup END

" Simulate Emacs' Fundamental mode
augroup DefaultFileType
    autocmd BufEnter *
                \ if &filetype == "" |
                \     set filetype=text | let b:default_filetype = 1 |
                \ endif
    autocmd BufWritePre * " Detect filetype after the first write
                \ if exists("b:default_filetype") |
                \     setlocal infercase< | setlocal textwidth< | filetype detect |
                \     unlet b:default_filetype |
                \ endif
augroup END

augroup InferCase
    autocmd!
    autocmd FileType gitcommit,mail,markdown,text setlocal ignorecase infercase
augroup END

let s:LargeXmlFile = 1024 * 512
augroup LargeXml
    autocmd BufRead * if &filetype =~# '\v(xml|html)'
            \| if getfsize(expand("<afile>")) > s:LargeXmlFile
                \| setlocal syntax=unknown | endif | endif
augroup END

augroup MailSetup
    autocmd!
    autocmd FileType mail call util#setupMatchit()
augroup END

function! s:XmlNavigate()
    nnoremap <buffer> <silent> [< <Cmd>call xml#NavigateDepthBackward(v:count1)<CR>
    nnoremap <buffer> <silent> ]> <Cmd>call xml#NavigateDepth(v:count1)<CR>
endfunction

augroup XmlNavigate
    autocmd!
    autocmd FileType html,javascriptreact,typescriptreact,xml call s:XmlNavigate()
augroup END

augroup TextWidth
    autocmd!
    autocmd FileType text setlocal textwidth=80
augroup END

augroup LuaSetup
    autocmd!
    autocmd FileType lua setlocal shiftwidth=2
augroup END

augroup SqlSetup
    autocmd!
    autocmd FileType sql setlocal indentexpr=indent
augroup END

function! s:MarkdownSetup()
    setlocal textwidth=80 tabstop=2 shiftwidth=2

    if exists(":EasyAlign")
        " Align markdown table
        nnoremap <buffer> <silent> <Space>t vip:EasyAlign*\|<CR>
    endif
endfunction

augroup MarkdownSetup
    autocmd!
    autocmd FileType markdown call s:MarkdownSetup()
augroup END

augroup GitCommit
    autocmd!
    autocmd BufWinEnter COMMIT_EDITMSG startinsert
augroup END

augroup SessionLoad
    autocmd!
    " Wiping empty buffers created by restoring sessions
    autocmd SessionLoadPost * silent call buffer#BWipeNotReadableForce()
augroup END

augroup TerminalSetup
    autocmd!
    " To enter Terminal-mode automatically:
    autocmd VimEnter * autocmd TerminalSetup TermOpen * startinsert
    autocmd TermEnter * set nonumber
augroup END
if v:vim_did_enter
    doautocmd TerminalSetup VimEnter
endif

augroup TabEvents
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

" Finish here if we haven't initialized the submodules

if glob(g:vim_dir."/pack/bundle/start/*/plugin") == ""
    finish
endif

" Subsection: package customisation {{{

" vim-commentary
augroup VimCommentary
    autocmd!
    autocmd FileType apache,crontab,debsources,desktop,fstab,samba setlocal commentstring=#\ %s
    autocmd FileType sql setlocal commentstring=--\ %s
augroup END

" vim-surround
augroup DisableSurroundIndent
    autocmd!
    autocmd FileType groovy,html,sql,xml let b:surround_indent = 0
augroup END

" CamelCase

map <silent> <Leader>w <Plug>CamelCaseMotion_w
map <silent> <Leader>b <Plug>CamelCaseMotion_b
map <silent> <Leader>e <Plug>CamelCaseMotion_e
map <silent> <Leader>ge <Plug>CamelCaseMotion_ge

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

" delimitMate

augroup DelimitMateSetup
    autocmd!
    autocmd FileType *clojure*,lisp,racket,scheme let b:loaded_delimitMate = 1
    autocmd FileType apache,html,xml let b:delimitMate_matchpairs = "(:),[:],{:},<:>"
    autocmd FileType sql let b:delimitMate_matchpairs = "(:),[:],{:}"
augroup END

" vim-quickhl

nmap <Space>m <Plug>(quickhl-manual-this)
xmap <Space>m <Plug>(quickhl-manual-this)
nmap <Space>M <Plug>(quickhl-manual-reset)
xmap <Space>M <Plug>(quickhl-manual-reset)

nmap <Space>w <Plug>(quickhl-manual-this-whole-word)
xmap <Space>w <Plug>(quickhl-manual-this-whole-word)

nmap <Space>c <Plug>(quickhl-manual-clear)
vmap <Space>c <Plug>(quickhl-manual-clear)

" dirvish

let g:loaded_netrwPlugin = 1
command! -nargs=? -complete=dir Explore Dirvish <args>

augroup DirvishSetup
    autocmd!
    autocmd FileType dirvish let b:Statusline_custom_leftline = '%<%{expand("%:h:t")}'
augroup END

" reply.vim
command! -nargs=0 ReplFile call reply#command#send(join(getline(1,line("$")),"\n"),0,0)

" Skipping nvim-jdtls autocmds and commands
let g:nvim_jdtls = 1

" }}}

" vim: fdm=marker
