" static snippets

function! s:GroovyStaticSnippets()
    abclear <buffer>
    iabbrev <buffer> printf sprintf("")<C-O>F"
    inoreabbrev <buffer> fmt printf
    inoreabbrev <buffer> /* /*<CR><Space>*<Space>*/<Up>
endfunction

function! s:JavaStaticSnippets()
    abclear <buffer>
    iabbrev <buffer> toStringm @Override<CR>public String toString()
                \ {<CR>}<C-o>Oreturn "";<Left><Left>
    inoreabbrev <buffer> tostr toStringm
    iabbrev <buffer> sysout System.out.println();<Left><Left>
    inoreabbrev <buffer> sysou sysout
    inoreabbrev <buffer> syso sysout
    iabbrev <buffer> syserr System.err.println();<Left><Left>
    inoreabbrev <buffer> syser syserr
    inoreabbrev <buffer> syse syserr
    inoreabbrev <buffer> mainm public static void main(final String[] args)<CR>{<CR>}<Up><CR>
    inoreabbrev <buffer> staticm public static void ()<CR>{<CR>}<Up><Up><C-O>t(<Right>
    inoreabbrev <buffer> publicm public void ()<CR>{<CR>}<Up><Up><C-O>t(<Right>
    inoreabbrev <buffer> privatem private void ()<CR>{<CR>}<Up><Up><C-O>t(<Right>
    inoreabbrev <buffer> protectedm protected void ()<CR>{<CR>}<Up><Up><C-O>t(<Right>
    iabbrev <buffer> formats String.format("")<C-O>F"
    inoreabbrev <buffer> fmt formats
    inoreabbrev <buffer> /* /*<CR>*/<Up>
endfunction

augroup StaticSnippets
    autocmd!
    autocmd FileType groovy call s:GroovyStaticSnippets()
    autocmd FileType java call s:JavaStaticSnippets()
augroup END
