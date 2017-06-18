command! BufWipeTab call MyVimGoodies#BufferGoodies#BufWipeTab()
command! -nargs=1 BufWipe call MyVimGoodies#BufferGoodies#BufWipe(<f-args>)
command! BufWipeTabOnly call MyVimGoodies#BufferGoodies#BufWipeTabOnly()
