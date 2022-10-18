let s:sysvimrcreadable = 0
let s:sysvimrc = ""

if has("win32") || has("win64")
    let s:sysvimrc = $VIM."/_vimrc"
endif

if has("unix")
    let s:sysvimrc = $VIM."/vimrc"
endif

if !empty(s:sysvimrc)
    exe "let s:sysvimrcreadable = filereadable('".s:sysvimrc."')"
endif

if s:sysvimrcreadable
    " skipping defaults.vim
    let skip_defaults_vim = 1
    exe "source ".s:sysvimrc
endif

if $XDG_CONFIG_HOME == ""
    let $XDG_CONFIG_HOME = "~/.config"
    if has("win32") || has("win64")
        let $XDG_CONFIG_HOME = "~/AppData/Local"
    endif
    let $XDG_CONFIG_HOME = fnamemodify($XDG_CONFIG_HOME,":p")
endif

if $XDG_DATA_HOME == ""
    let $XDG_DATA_HOME = "~/.local/share"
    if has("win32") || has("win64")
        let $XDG_DATA_HOME = "~/AppData/Local"
    endif
    let $XDG_DATA_HOME = fnamemodify($XDG_DATA_HOME,":p")
endif

if has("win32") || has("win64")
    set runtimepath-=$HOME/vimfiles
    set runtimepath-=$HOME/vimfiles/after
else
    set runtimepath-=$HOME/.vim
    set runtimepath-=$HOME/.vim/after
endif

if has("nvim")
    set runtimepath-=$XDG_CONFIG_HOME/nvim
    set runtimepath-=$XDG_CONFIG_HOME/nvim/after
    set runtimepath-=$XDG_DATA_HOME/nvim/site
    set runtimepath-=$XDG_DATA_HOME/nvim/site/after
endif

if has("packages")
    if has("win32") || has("win64")
        set packpath-=$HOME/vimfiles
        set packpath-=$HOME/vimfiles/after
    else
        set packpath-=$HOME/.vim
        set packpath-=$HOME/.vim/after
    endif
    if has("nvim")
        set packpath-=$XDG_CONFIG_HOME/nvim
        set packpath-=$XDG_CONFIG_HOME/nvim/after
        set runtimepath-=$XDG_DATA_HOME/nvim/site
        set runtimepath-=$XDG_DATA_HOME/nvim/site/after
    endif
endif

let g:vim_dir = expand("<sfile>:p:h")
let s:vim_dir = fnameescape(g:vim_dir)
exe "set runtimepath+=".s:vim_dir
exe "set runtimepath+=".s:vim_dir."/after"
if has("packages")
    exe "set packpath+=".s:vim_dir
    exe "set packpath+=".s:vim_dir."/after"
endif

" sourcing init.vim

let s:init = g:vim_dir . "/init.vim"
if filereadable(s:init)
    execute "source " . fnameescape(s:init)
endif
