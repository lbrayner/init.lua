if !executable('svn')
  finish
endif

command! -nargs=* SVNDiffCursor call MyVimGoodies#SVNGoodies#SVNDiffCursor(<f-args>)
command! -nargs=* SVNDiffThis call MyVimGoodies#SVNGoodies#SVNDiffThis(<f-args>)

nnoremap <Plug>MVGSVNDiffCursor :call MyVimGoodies#SVNGoodies#SVNDiffCursor()<CR>
