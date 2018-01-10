
" set gfn=Inconsolata\ for\ Powerline\ Medium\ 12
set gfn=Consolas:h10.5
set guicursor+=a:blinkon0
set guioptions-=m  "remove menu bar
set guioptions-=T  "remove toolbar
set guioptions-=r  "remove right-hand scroll bar
set guioptions-=L  "remove left-hand scroll bar
set guioptions+=c

" set up tab labels with tab number, buffer name, number of windows
function! GuiTabLabel()
  let label = ''
  " let bufnrlist = tabpagebuflist(v:lnum)
  " " Add '+' if one of the buffers in the tab page is modified
  " for bufnr in bufnrlist
  "   if getbufvar(bufnr, "&modified")
  "     let label = '+'
  "     break
  "   endif
  " endfor
  " Append the number of windows in the tab page
  let wincount = tabpagewinnr(v:lnum, '$')
  let  label .= wincount . ': '
  " Append the buffer name
  " let name = bufname(bufnrlist[tabpagewinnr(v:lnum) - 1])
  " if name == ''
  "   " give a name to no-name documents
  "   if &buftype=='quickfix'
  "     let name = '[Quickfix List]'
  "   else
  "     let name = '[No Name]'
  "   endif
  " else
  "   " get only the file name
  "   let name = fnamemodify(name,":t")
  " endif
  " let label .= name
  " Append the CWD
  let directory = fnamemodify(getcwd(),':t')
  let label .= ' ' . directory
  " Append the tab number
  let  label .= '  [' . v:lnum . ']'
  return label
endfunction
set guitablabel=%{GuiTabLabel()}
