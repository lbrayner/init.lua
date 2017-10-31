if !executable('git')
  finish
endif

command! -nargs=* GitDiffCursor call MyVimGoodies#GitGoodies#GitDiffCursor(<f-args>)
command! -nargs=* GitDiffThis call MyVimGoodies#GitGoodies#GitDiffThis(<f-args>)
command! -nargs=0 GitDiffContextual call MyVimGoodies#GitGoodies#GitDiffContextual()
command! -nargs=0 GitStatus call MyVimGoodies#GitGoodies#GitStatus()

nnoremap <silent> <Plug>MVGGitDiffCursor :call MyVimGoodies#GitGoodies#GitDiffCursor()<CR>
nnoremap <silent> <Plug>MVGGitDiffThis :call MyVimGoodies#GitGoodies#GitDiffThis()<CR>
nnoremap <silent> <Plug>MVGGitDiffThisExtDiff
            \ :call MyVimGoodies#GitGoodies#GitDiffThis("--ext-diff")<CR>
nnoremap <silent> <Plug>MVGGitDiffContextual
            \ :call MyVimGoodies#GitGoodies#GitDiffContextual()<CR>
nnoremap <silent> <Plug>MVGGitStatus :call MyVimGoodies#GitGoodies#GitStatus()<CR>
