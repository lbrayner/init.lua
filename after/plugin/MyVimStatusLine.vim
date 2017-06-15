try
    call MyVimStatusLine#extensions#eclim#EclimAvailable()
    call MyVimStatusLine#extensions#eclim#DefineEclimStatusLine()
catch /E117/ 
    call MyVimStatusLine#statusline#DefineDefaultStatusLine()
endtry

call MyVimStatusLine#initialize()

call MyVimStatusLine#HighlightMode('normal')
call MyVimStatusLine#HighlightStatusLineNC()
