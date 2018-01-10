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
set guioptions+=c

" http://vim.wikia.com/wiki/Show_tab_number_in_your_tab_line

" set up tab labels with tab number, buffer name, number of windows
function! GuiTabLabel()
  let label = ''
  let wincount = tabpagewinnr(v:lnum, '$')
  let  label .= wincount . ': '
  " Append the CWD
  let directory = fnamemodify(getcwd(),':t')
  let label .= ' ' . directory
  " Append the tab number
  let  label .= '  [' . v:lnum . ']'
  return label
endfunction
set guitablabel=%{GuiTabLabel()}
