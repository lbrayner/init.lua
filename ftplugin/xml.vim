let b:delimitMate_matchpairs = "(:),[:],{:},<:>"

command! -buffer -nargs=+ JasperVerticalDisplacement
            \ call jasper#JasperVerticalDisplacement(<f-args>)

command! -buffer -nargs=+ JasperHorizontalDisplacement
            \ call jasper#JasperHorizontalDisplacement(<f-args>)
