if $XDG_CONFIG_HOME == ""
    let $XDG_CONFIG_HOME = "~/.config"
    let $XDG_CONFIG_HOME = fnamemodify($XDG_CONFIG_HOME,":p")
endif

if $XDG_DATA_HOME == ""
    let $XDG_DATA_HOME = "~/.local/share"
    let $XDG_DATA_HOME = fnamemodify($XDG_DATA_HOME,":p")
endif

set runtimepath-=$XDG_CONFIG_HOME/nvim
set runtimepath-=$XDG_CONFIG_HOME/nvim/after
set runtimepath-=$XDG_DATA_HOME/nvim/site
set runtimepath-=$XDG_DATA_HOME/nvim/site/after

set packpath-=$XDG_CONFIG_HOME/nvim
set packpath-=$XDG_CONFIG_HOME/nvim/after
set packpath-=$XDG_DATA_HOME/nvim/site
set packpath-=$XDG_DATA_HOME/nvim/site/after

if $MYVIMRC != ""
    let g:vim_dir = fnamemodify($MYVIMRC,":p:h")
    exe "set runtimepath+=".g:vim_dir
    exe "set runtimepath+=".g:vim_dir."/after"
    exe "set packpath+=".g:vim_dir
    exe "set packpath+=".g:vim_dir."/after"
endif

if $MYVIMRC != ""
    let vimrc = $MYVIMRC
    let $MYVIMRC = ""
    exe "source ".vimrc
endif
