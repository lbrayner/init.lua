if !executable('git')
  finish
endif

call util#vimmap('nmap <unique>','<leader>G','<Plug>MVGGitDiffContextual')
