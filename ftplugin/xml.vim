let b:delimitMate_matchpairs = "(:),[:],{:},<:>"

command! -buffer -range=% -nargs=+ JasperVerticalDisplacement
            \ call jasper#JasperVerticalDisplacement(<line1>,<line2>,<f-args>)

command! -buffer -range=% -nargs=+ JasperHorizontalDisplacement
            \ call jasper#JasperHorizontalDisplacement(<line1>,<line2>,<f-args>)
