if !executable('svn')
  finish
endif

call util#vimmap('nmap <unique>','<leader>D','<Plug>MVGSVNDiffContextual')
