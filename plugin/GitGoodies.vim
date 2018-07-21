if !executable('git')
  finish
endif

command! -nargs=* GitDiffCursor call GitGoodies#GitDiffCursor(<f-args>)
command! -nargs=* GitDiffThis call GitGoodies#GitDiffThis(<f-args>)
command! -nargs=0 GitDiffContextual call GitGoodies#GitDiffContextual()
command! -nargs=0 GitStatus call GitGoodies#GitStatus()

nnoremap <silent> <Plug>MVGGitDiffCursor :call GitGoodies#GitDiffCursor()<CR>
nnoremap <silent> <Plug>MVGGitDiffThis :call GitGoodies#GitDiffThis()<CR>
nnoremap <silent> <Plug>MVGGitDiffThisExtDiff
            \ :call GitGoodies#GitDiffThis("--ext-diff")<CR>
nnoremap <silent> <Plug>MVGGitDiffContextual
            \ :call GitGoodies#GitDiffContextual()<CR>
nnoremap <silent> <Plug>MVGGitStatus :call GitGoodies#GitStatus()<CR>
