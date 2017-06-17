if !executable('svn')
  finish
endif

command! -nargs=0 SVNDiffCursor call MyVimGoodies#SVNGoodies#SVNDiffCursor()
command! -nargs=0 SVNDiffThis call MyVimGoodies#SVNGoodies#SVNDiffThis()

nnoremap <Plug>MVGSVNDiffCursor :call MyVimGoodies#SVNGoodies#SVNDiffCursor()<CR>
