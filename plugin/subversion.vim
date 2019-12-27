if !executable('svn')
  finish
endif

command! SVNDiffCursor call subversion#SVNDiffCursor()
command! SVNDiffThis call subversion#SVNDiffThis()
command! SVNDiffContextual call subversion#SVNDiffContextual()

command! -nargs=* SVNLog !svn log -rHEAD:1 -l1 % <args>

nnoremap <silent> <leader>D :SVNDiffContextual<CR>
