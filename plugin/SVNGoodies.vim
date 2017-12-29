if !executable('svn')
  finish
endif

command! -nargs=* SVNDiffCursor call MyVimGoodies#SVNGoodies#SVNDiffCursor(<f-args>)
command! -nargs=* SVNDiffThis call MyVimGoodies#SVNGoodies#SVNDiffThis(<f-args>)
command! -nargs=0 SVNDiffContextual call MyVimGoodies#SVNGoodies#SVNDiffContextual()

nnoremap <silent> <Plug>MVGSVNDiffCursor :call MyVimGoodies#SVNGoodies#SVNDiffCursor()<CR>
nnoremap <silent> <Plug>MVGSVNDiffThis :call MyVimGoodies#SVNGoodies#SVNDiffThis()<CR>
nnoremap <silent> <Plug>MVGSVNDiffThisIgnoreAllWS
            \ :call MyVimGoodies#SVNGoodies#SVNDiffThis("-x -w")<CR>
nnoremap <silent> <Plug>MVGSVNDiffContextual
            \ :call MyVimGoodies#SVNGoodies#SVNDiffContextual()<CR>
