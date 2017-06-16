if MyVimStatusLine#extensions#eclim#EclimLoaded()
    call MyVimStatusLine#extensions#eclim#DefineEclimStatusLine()
else
    call MyVimStatusLine#statusline#DefineDefaultStatusLine()
endif

call MyVimStatusLine#initialize()

call MyVimStatusLine#HighlightMode('normal')
call MyVimStatusLine#HighlightStatusLineNC()
