" if !executable('svn')
"   finish
" endif

" let s:leader = '\'

" if exists("mapleader")
"     let s:leader = mapleader
" endif

" if ! hasmapto(s:leader."D")
"     nnoremap <silent> <leader>D :SVNDiffThis<cr>
" endif

" if ! hasmapto('<Plug>MVGSVNDiffCursor')
"     nmap 0sd <Plug>MVGSVNDiffCursor
" endif

if !executable('svn')
  finish
endif

call MyVimGoodies#util#vimmap('nmap <unique>','<leader>D','<Plug>MVGSVNDiffContextual')
