if &ft == 'qf'
    let b:Statusline_custom_leftline = '%<'
            \ . '%f'
            \ . '%{statusline#DefaultModifiedFlag()}%='
endif
