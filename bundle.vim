if $XDG_CONFIG_HOME == ""
    let $XDG_CONFIG_HOME = fnamemodify(stdpath("config"), ":h:p")
endif

if $XDG_DATA_HOME == ""
    let $XDG_DATA_HOME = fnamemodify(stdpath("data"), ":h:p")
endif

set runtimepath-=$XDG_CONFIG_HOME/nvim
set runtimepath-=$XDG_CONFIG_HOME/nvim/after
set runtimepath-=$XDG_DATA_HOME/nvim/site
set runtimepath-=$XDG_DATA_HOME/nvim/site/after

set packpath-=$XDG_CONFIG_HOME/nvim
set packpath-=$XDG_CONFIG_HOME/nvim/after
set packpath-=$XDG_DATA_HOME/nvim/site
set packpath-=$XDG_DATA_HOME/nvim/site/after

let s:vim_dir = expand("<sfile>:p:h")
let s:_vim_dir_ = fnameescape(s:vim_dir)
exe "set runtimepath+=".s:_vim_dir_
exe "set runtimepath+=".s:_vim_dir_."/after"
exe "set packpath+=".s:_vim_dir_
exe "set packpath+=".s:_vim_dir_."/after"

" sourcing init.vim

let s:init = s:vim_dir . "/init.vim"
if filereadable(s:init)
    execute "source " . fnameescape(s:init)
endif
