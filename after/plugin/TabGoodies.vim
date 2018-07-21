call util#vimmap('map','<Plug>GoToTab'
            \ ,':call TabGoodies#GoToTab()<cr>')
call util#vimmap('nmap <silent>','<F8>','<Plug>GoToTab')

call util#vimmap('nmap <silent>','<Leader><f8>'
            \ ,':call TabGoodies#GoToLastTab()<cr>')
