command! BufWipeNotLoaded call MyVimGoodies#BufferGoodies#BufWipeNotLoaded()
command! BufWipeTab call MyVimGoodies#BufferGoodies#BufWipeTab()
command! -nargs=1 BufWipe call MyVimGoodies#BufferGoodies#BufWipe(<f-args>)
command! -nargs=1 BufWipeForce call MyVimGoodies#BufferGoodies#BufWipeForce(<f-args>)
command! -nargs=1 BufWipeHidden call MyVimGoodies#BufferGoodies#BufWipeHidden(<f-args>)
command! BufWipeTabOnly call MyVimGoodies#BufferGoodies#BufWipeTabOnly()
command! -nargs=1 BufWipeFileType call MyVimGoodies#BufferGoodies#BufWipeFileType(<f-args>)
