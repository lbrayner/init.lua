call util#vimmap('map','<Plug>GoToTab'
            \ ,':call tab#GoToTab()<cr>')
call util#vimmap('nmap <silent>','<F8>','<Plug>GoToTab')

call util#vimmap('nmap <silent>','<Leader><f8>'
            \ ,':call tab#GoToLastTab()<cr>')
