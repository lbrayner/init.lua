set guicursor+=a:blinkon0
set guioptions-=m  "remove menu bar
set guioptions-=T  "remove toolbar
set guioptions-=r  "remove right-hand scroll bar
set guioptions-=L  "remove left-hand scroll bar
set guioptions-=e  "do not use guitablabel
set guioptions+=c

if has("win32") || has("win64")
    set gfn=Consolas:h10.5
endif
