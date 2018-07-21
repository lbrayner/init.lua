if !executable('svn')
  finish
endif

command! -nargs=* SVNDiffCursor call SVNGoodies#SVNDiffCursor(<f-args>)
command! -nargs=* SVNDiffThis call SVNGoodies#SVNDiffThis(<f-args>)
command! -nargs=0 SVNDiffContextual call SVNGoodies#SVNDiffContextual()

command! -nargs=* SVNLog !svn log -rHEAD:1 -l1 % <args>

nnoremap <silent> <Plug>MVGSVNDiffCursor :call SVNGoodies#SVNDiffCursor()<CR>
nnoremap <silent> <Plug>MVGSVNDiffThis :call SVNGoodies#SVNDiffThis()<CR>
nnoremap <silent> <Plug>MVGSVNDiffThisIgnoreAllWS
            \ :call SVNGoodies#SVNDiffThis("-x -w")<CR>
nnoremap <silent> <Plug>MVGSVNDiffContextual
            \ :call SVNGoodies#SVNDiffContextual()<CR>
