function initializer#initialize()
    let g:status_vmode='cterm'

    if has('gui_running')
        let g:status_vmode='gui'
    endif

    if has('gui_running')
        let g:normal_bg='#5f87ff'
        let g:normal_fg='#121212'

        let g:insert_bg='#121212'
        let g:insert_fg='#00ff87'

        let g:user2_normal_bg='#121212'
        let g:user2_normal_fg='#d7005f'

        let g:user2_insert_bg=g:insert_fg
        let g:user2_insert_fg='Purple'

        let g:user3_normal_bg='#121212'
        let g:user3_normal_fg='DarkGray'

        let g:user3_insert_bg=g:insert_fg
        let g:user3_insert_fg='Orange'

        let g:user4_normal_bg='#121212'
        let g:user4_normal_fg='DarkGray'

        let g:user4_insert_bg=g:insert_fg
        let g:user4_insert_fg='Orange'

        let g:not_current_bg='DarkGray'
        let g:not_current_fg='#121212'
    else
        let g:statusline_normal='NONE'
        let g:statusline_insert='bold'

        " let g:statusline_attr_list='NONE'
        let g:statuslinenc='NONE'

        let g:normal_bg='233'
        let g:normal_fg='69'

        let g:insert_bg='48'
        let g:insert_fg='233'

        let g:user1_normal_bg='233'
        let g:user1_normal_fg='183'

        let g:user1_insert_bg=g:insert_bg
        let g:user1_insert_fg='172'

        let g:user2_normal_bg='233'
        let g:user2_normal_fg='161'

        let g:user2_insert_bg=g:insert_bg
        let g:user2_insert_fg='54'

        let g:user3_normal_bg='233'
        let g:user3_normal_fg='DarkGray'

        let g:user3_insert_bg=g:insert_bg
        let g:user3_insert_fg='172'

        let g:user4_normal_bg='233'
        let g:user4_normal_fg='DarkGray'

        let g:user4_insert_bg=g:insert_bg
        let g:user4_insert_fg='172'

        let g:user5_normal_bg='233'
        let g:user5_normal_fg='DarkGray'

        let g:user5_insert_bg=g:insert_bg
        let g:user5_insert_fg='172'

        let g:not_current_bg='233'
        let g:not_current_fg='DarkGrey'
    endif
endfunction
