call MyVimGoodies#util#vimmap('map','<Plug>GoToTab'
            \ ,':call MyVimGoodies#TabGoodies#GoToTab()<cr>')
call MyVimGoodies#util#vimmap('nmap <silent>','<F8>','<Plug>GoToTab')

call MyVimGoodies#util#vimmap('nmap <silent>','<Leader><f8>'
            \ ,':call MyVimGoodies#TabGoodies#GoToLastTab()<cr>')
