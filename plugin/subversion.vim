if !executable('svn')
  finish
endif

command! SVNDiffCursor call subversion#SVNDiffCursor()
command! SVNDiffThis call subversion#SVNDiffThis()
command! SVNDiffContextual call subversion#SVNDiffContextual()
