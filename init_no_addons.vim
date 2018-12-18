if $XDG_CONFIG_HOME == ''
    let $XDG_CONFIG_HOME = '~/.config'
    if has("win32")
        let $XDG_CONFIG_HOME = '~/AppData/Local'
    endif
    let $XDG_CONFIG_HOME = fnamemodify($XDG_CONFIG_HOME,":p")
endif

if has("win32")
    set runtimepath-=$HOME/vimfiles
    set runtimepath-=$HOME/vimfiles/after
else
    set runtimepath-=$HOME/.vim
    set runtimepath-=$HOME/.vim/after
endif

if has("nvim")
    set runtimepath-=$XDG_CONFIG_HOME/nvim
    set runtimepath-=$XDG_CONFIG_HOME/nvim/after
endif

if has('packages')
    if has("win32")
        set packpath-=$HOME/vimfiles
        set packpath-=$HOME/vimfiles/after
    else
        set packpath-=$HOME/.vim
        set packpath-=$HOME/.vim/after
    endif
    if has("nvim")
        set packpath-=$XDG_CONFIG_HOME/nvim
        set packpath-=$XDG_CONFIG_HOME/nvim/after
    endif
endif

let sysvimrcreadable = 0
let sysvimrc = ""

if has("win32")
    let sysvimrc = $VIM."/_vimrc"
endif

if has("unix")
    let sysvimrc = $VIM."/vimrc"
endif

if !empty(sysvimrc)
    exe "let sysvimrcreadable = filereadable('".sysvimrc."')"
endif

if sysvimrcreadable
    exe "source ".sysvimrc
endif

if $MYVIMRC != ''
    let g:vim_dir = expand('<sfile>:p:h')
    exe "set runtimepath+=".g:vim_dir
    exe "set runtimepath+=".g:vim_dir."/after"
endif

if $MYVIMRC != ''
    let vimrc = $MYVIMRC
    let $MYVIMRC = ''
    exe "source ".vimrc
endif
