function! MyVimGoodies#extensions#eclim#EclimAvailable()
    return eclim#EclimAvailable(0)
endfunction

let s:search_element =
    \ '-command <search> -n "<project>" -f "<file>" ' .
    \ '-o <offset> -e <encoding> -l <length> <args>'

function! MyVimGoodies#extensions#eclim#EclimGoToClassDeclarationLine()
    call eclim#java#search#SearchAndDisplay('java_search', '-p '.expand('%:t:r').' -x declarations'
                \ .' -s project')
endfunction
