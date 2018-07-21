function! extensions#eclim#EclimAvailable()
    return eclim#EclimAvailable(0)
endfunction

let s:search_element =
    \ '-command <search> -n "<project>" -f "<file>" ' .
    \ '-o <offset> -e <encoding> -l <length> <args>'

function! extensions#eclim#EclimGoToClassDeclarationLine()
    let package = eclim#java#util#GetPackage()
    silent! call eclim#java#search#SearchAndDisplay('java_search',
                \ '-p '
                \ .package."."
                \ .expand('%:t:r')
                \ . ' -x declarations'
                \ .' -s project'
                \ )
endfunction
