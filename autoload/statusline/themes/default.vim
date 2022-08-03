function! statusline#themes#default#getColorMapping()
    let colorMapping = {
        \ 'normal_bg': 'x233_Grey7',
        \ 'normal_fg': 'x069_CornflowerBlue',
        \ 'visual_bg': 'x123_DarkSlateGray1',
        \ 'visual_fg': 'x233_Grey7',
        \ 'insert_bg': 'x048_SpringGreen1',
        \ 'insert_fg': 'x233_Grey7',
        \ 'command_bg': 'x069_CornflowerBlue',
        \ 'command_fg': 'x233_Grey7',
        \ 'terminal_bg': 'x233_Grey7',
        \ 'terminal_fg': 'x069_CornflowerBlue',
        \ 'search_bg': 'x166_DarkOrange3',
        \ 'search_fg': 'x233_Grey7',
        \ 'user1_normal_bg': 'x233_Grey7',
        \ 'user1_normal_fg': 'x161_DeepPink3',
        \ 'user1_visual_bg': 'x123_DarkSlateGray1',
        \ 'user1_visual_fg': 'x161_DeepPink3',
        \ 'user1_insert_bg': 'x048_SpringGreen1',
        \ 'user1_insert_fg': 'x161_DeepPink3',
        \ 'user1_command_bg': 'x069_CornflowerBlue',
        \ 'user1_command_fg': 'x124_Red3',
        \ 'user1_terminal_bg': 'x233_Grey7',
        \ 'user1_terminal_fg': 'x161_DeepPink3',
        \ 'user1_search_bg': 'x166_DarkOrange3',
        \ 'user1_search_fg': 'x124_Red3',
        \ 'user2_normal_bg': 'x233_Grey7',
        \ 'user2_normal_fg': 'x183_Plum2',
        \ 'user2_visual_bg': 'x123_DarkSlateGray1',
        \ 'user2_visual_fg': 'x233_Grey7',
        \ 'user2_insert_bg': 'x048_SpringGreen1',
        \ 'user2_insert_fg': 'x233_Grey7',
        \ 'user2_command_bg': 'x069_CornflowerBlue',
        \ 'user2_command_fg': 'x233_Grey7',
        \ 'user2_terminal_bg': 'x233_Grey7',
        \ 'user2_terminal_fg': 'x183_Plum2',
        \ 'user2_search_bg': 'x166_DarkOrange3',
        \ 'user2_search_fg': 'x233_Grey7',
        \ 'user3_normal_bg': 'x233_Grey7',
        \ 'user3_normal_fg': 'x161_DeepPink3',
        \ 'user3_visual_bg': 'x123_DarkSlateGray1',
        \ 'user3_visual_fg': 'x161_DeepPink3',
        \ 'user3_insert_bg': 'x048_SpringGreen1',
        \ 'user3_insert_fg': 'x054_Purple4',
        \ 'user3_command_bg': 'x069_CornflowerBlue',
        \ 'user3_command_fg': 'x161_DeepPink3',
        \ 'user3_terminal_bg': 'x233_Grey7',
        \ 'user3_terminal_fg': 'x161_DeepPink3',
        \ 'user3_search_bg': 'x166_DarkOrange3',
        \ 'user3_search_fg': 'x054_Purple4',
        \ 'user4_normal_bg': 'x233_Grey7',
        \ 'user4_normal_fg': 'x240_Grey35',
        \ 'user4_visual_bg': 'x123_DarkSlateGray1',
        \ 'user4_visual_fg': 'x128_DarkViolet',
        \ 'user4_insert_bg': 'x048_SpringGreen1',
        \ 'user4_insert_fg': 'x172_Orange3',
        \ 'user4_command_bg': 'x069_CornflowerBlue',
        \ 'user4_command_fg': 'x240_Grey35',
        \ 'user4_terminal_bg': 'x233_Grey7',
        \ 'user4_terminal_fg': 'x240_Grey35',
        \ 'user4_search_bg': 'x166_DarkOrange3',
        \ 'user4_search_fg': 'x124_Red3',
        \ 'user5_normal_bg': 'x233_Grey7',
        \ 'user5_normal_fg': 'x248_Grey66',
        \ 'user5_visual_bg': 'x123_DarkSlateGray1',
        \ 'user5_visual_fg': 'x233_Grey7',
        \ 'user5_insert_bg': 'x048_SpringGreen1',
        \ 'user5_insert_fg': 'x233_Grey7',
        \ 'user5_command_bg': 'x069_CornflowerBlue',
        \ 'user5_command_fg': 'x240_Grey35',
        \ 'user5_terminal_bg': 'x233_Grey7',
        \ 'user5_terminal_fg': 'x248_Grey66',
        \ 'user5_search_bg': 'x166_DarkOrange3',
        \ 'user5_search_fg': 'x233_Grey7',
        \ 'user6_normal_bg': 'x233_Grey7',
        \ 'user6_normal_fg': 'x100_Yellow4',
        \ 'user6_visual_bg': 'x123_DarkSlateGray1',
        \ 'user6_visual_fg': 'x240_Grey35',
        \ 'user6_insert_bg': 'x048_SpringGreen1',
        \ 'user6_insert_fg': 'x240_Grey35',
        \ 'user6_command_bg': 'x069_CornflowerBlue',
        \ 'user6_command_fg': 'x183_Plum2',
        \ 'user6_terminal_bg': 'x233_Grey7',
        \ 'user6_terminal_fg': 'x100_Yellow4',
        \ 'user6_search_bg': 'x166_DarkOrange3',
        \ 'user6_search_fg': 'x240_Grey35',
        \ 'user7_normal_bg': 'x233_Grey7',
        \ 'user7_normal_fg': 'x166_DarkOrange3',
        \ 'user7_visual_bg': 'x123_DarkSlateGray1',
        \ 'user7_visual_fg': 'x166_DarkOrange3',
        \ 'user7_insert_bg': 'x048_SpringGreen1',
        \ 'user7_insert_fg': 'x056_Purple3',
        \ 'user7_command_bg': 'x069_CornflowerBlue',
        \ 'user7_command_fg': 'x056_Purple3',
        \ 'user7_terminal_bg': 'x022_DarkGreen',
        \ 'user7_terminal_fg': 'x233_Grey7',
        \ 'user7_search_bg': 'x166_DarkOrange3',
        \ 'user7_search_fg': 'x239_Grey30',
        \ 'not_current_bg': 'x234_Grey11',
        \ 'not_current_fg': 'x240_Grey35'}
    return colorMapping
endfunction

function! statusline#themes#default#getTermAttrList()
    let termAttrList = {
        \ 'statuslinenc': 'NONE',
        \ 'statusline_modified': 'NONE',
        \ 'statusline_nomodified': 'NONE',
        \ 'statusline_normal': 'bold',
        \ 'statusline_visual': 'bold',
        \ 'statusline_insert': 'bold',
        \ 'statusline_command': 'bold',
        \ 'statusline_terminal': 'bold',
        \ 'statusline_search': 'bold'}
    return termAttrList
endfunction
