let s:has_windows = 0
if has('win32') || has('win64')
    let s:has_windows = 1
endif

set gfn=Inconsolata\ for\ Powerline\ Medium\ 12

if s:has_windows
    set gfn=Consolas:h10.5
endif

set guicursor+=a:blinkon0
set guioptions-=m  "remove menu bar
set guioptions-=T  "remove toolbar
set guioptions-=r  "remove right-hand scroll bar
set guioptions-=L  "remove left-hand scroll bar
set guioptions-=e  "do not use guitablabel
set guioptions+=c
