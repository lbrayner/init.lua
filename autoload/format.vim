function! s:QuoteByteIndex(escape,quote,code,...)
    let start = strlen(a:code)
    if a:0 > 0
        let start = a:1
    endif
    let index = strridx(a:code,a:quote,start)
    while strpart(a:code,index-1,1) == a:escape
        let x = index-1
        let bcount = 0
        while strpart(a:code,x,1) == a:escape
            let bcount = bcount + 1
            let x = x - 1
        endwhile
        if bcount % 2 == 0
            return index
        endif
        let index = strridx(a:code,a:quote,x)
    endwhile
    return index
endfunction

function! format#QuoteByteIndices(escape,quote,code)
    let lastquote = s:QuoteByteIndex(a:escape,a:quote,a:code)
    let lastquote2 = s:QuoteByteIndex(a:escape,a:quote,a:code,lastquote - 1)

    if lastquote < 0 || lastquote2 < 0
        return v:null
    endif

    if lastquote2 > g:java#format#length
                \ || lastquote < g:java#format#length
        return v:null
    endif

    return {"left" : lastquote2, "right" : lastquote}
endfunction
