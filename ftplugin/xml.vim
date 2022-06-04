let b:delimitMate_matchpairs = "(:),[:],{:},<:>"

command! -buffer -range=% -nargs=+ JasperVerticalDisplacement
            \ call jasper#JasperVerticalDisplacement(<line1>,<line2>,<f-args>)

command! -buffer -range=% -nargs=+ JasperHorizontalDisplacement
            \ call jasper#JasperHorizontalDisplacement(<line1>,<line2>,<f-args>)

let b:surround_indent = 0

nnoremap <buffer> <silent> [< :call xml#NavigateDepthBackward(v:count1)<cr>
nnoremap <buffer> <silent> ]> :call xml#NavigateDepth(v:count1)<cr>
