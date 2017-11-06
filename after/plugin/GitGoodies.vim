if !executable('git')
  finish
endif

call MyVimGoodies#util#vimmap('nmap <unique>','<leader>G','<Plug>MVGGitDiffContextual')
