if !executable('svn')
  finish
endif

command! Scursor call subversion#SVNDiffCursor()
command! Sthis call subversion#SVNDiffThis()
command! Sdiff call subversion#SVNDiffContextual()
