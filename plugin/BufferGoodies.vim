command! BufWipeTab call MyVimGoodies#BufferGoodies#BufWipeTab()
command! -nargs=? BufWipe call MyVimGoodies#BufferGoodies#BufWipe(<f-args>)
command! BufWipeTabOnly call MyVimGoodies#BufferGoodies#BufWipeTabOnly()
command! -nargs=? BufWipeFileType call MyVimGoodies#BufferGoodies#BufWipeFileType(<f-args>)
