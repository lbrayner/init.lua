function! MyVimStatusLine#themes#default#getColorMapping()
    let colorMapping = {
        \ 'normal_bg': 'x233_Grey7',
        \ 'normal_fg': 'x069_CornflowerBlue',
        \ 'insert_bg': 'x048_SpringGreen1',
        \ 'insert_fg': 'x233_Grey7',
        \ 'user1_normal_bg': 'x233_Grey7',
        \ 'user1_insert_bg': 'x048_SpringGreen1',
        \ 'user1_modified_fg': 'x161_DeepPink3',
        \ 'user2_normal_bg': 'x233_Grey7',
        \ 'user2_normal_fg': 'x183_Plum2',
        \ 'user2_insert_bg': 'x048_SpringGreen1',
        \ 'user2_insert_fg': 'x172_Orange3',
        \ 'user3_normal_bg': 'x233_Grey7',
        \ 'user3_normal_fg': 'x161_DeepPink3',
        \ 'user3_insert_bg': 'x048_SpringGreen1',
        \ 'user3_insert_fg': 'x054_Purple4',
        \ 'user4_normal_bg': 'x233_Grey7',
        \ 'user4_normal_fg': 'x240_Grey35',
        \ 'user4_insert_bg': 'x048_SpringGreen1',
        \ 'user4_insert_fg': 'x172_Orange3',
        \ 'user5_normal_bg': 'x233_Grey7',
        \ 'user5_normal_fg': 'x166_DarkOrange3',
        \ 'user5_insert_bg': 'x048_SpringGreen1',
        \ 'user5_insert_fg': 'x240_Grey35',
        \ 'user6_normal_bg': 'x233_Grey7',
        \ 'user6_normal_fg': 'x240_Grey35',
        \ 'user6_insert_bg': 'x048_SpringGreen1',
        \ 'user6_insert_fg': 'x172_Orange3',
        \ 'not_current_bg': 'x236_Grey19',
        \ 'not_current_fg': 'x240_Grey35'}
    return colorMapping
endfunction

function! MyVimStatusLine#themes#default#getTermAttrList()
    let termAttrList = {
        \ 'statuslinenc': 'NONE',
        \ 'statusline_modified': 'NONE',
        \ 'statusline_nomodified': 'NONE',
        \ 'statusline_normal': 'bold',
        \ 'statusline_insert': 'bold'}
    return termAttrList
endfunction
