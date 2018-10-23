if !executable('svn')
  finish
endif

command! -nargs=* SVNDiffCursor call subversion#SVNDiffCursor(<f-args>)
command! -nargs=* SVNDiffThis call subversion#SVNDiffThis(<f-args>)
command! -nargs=0 SVNDiffContextual call subversion#SVNDiffContextual()

command! -nargs=* SVNLog !svn log -rHEAD:1 -l1 % <args>

nnoremap <silent> <Plug>MVGSVNDiffCursor :call subversion#SVNDiffCursor()<CR>
nnoremap <silent> <Plug>MVGSVNDiffThis :call subversion#SVNDiffThis()<CR>
nnoremap <silent> <Plug>MVGSVNDiffThisIgnoreAllWS
            \ :call subversion#SVNDiffThis("-w")<CR>
nnoremap <silent> <Plug>MVGSVNDiffContextual
            \ :call subversion#SVNDiffContextual()<CR>

call util#vimmap('nmap <unique>','<leader>D','<Plug>MVGSVNDiffContextual')
