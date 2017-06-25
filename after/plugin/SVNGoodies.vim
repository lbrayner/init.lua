if !executable('svn')
  finish
endif

call MyVimGoodies#util#vimmap('nmap <unique>','<leader>D','<Plug>MVGSVNDiffContextual')
