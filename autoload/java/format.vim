let g:java#format#length = 80

function! s:QuoteByteIndex(code,...)
    let start = strlen(a:code)
    if a:0 > 0
        let start = a:1
    endif
    let index = strridx(a:code, '"',start)
    while strpart(a:code,index-1,1) == '\'
        let x = index-1
        let bcount = 0
        while strpart(a:code,x,1) == '\'
            let bcount = bcount + 1
            let x = x - 1
        endwhile
        if bcount % 2 == 0
            return index
        endif
        let index = strridx(a:code,'"',index - 1)
    endwhile
    return index
endfunction

function! s:QuoteByteIndices(code)
    let lastquote = s:QuoteByteIndex(a:code)
    let lastquote2 = s:QuoteByteIndex(a:code,lastquote - 1)

    if lastquote < 0 || lastquote2 < 0
        return v:null
    endif

    if lastquote2 > g:java#format#length
                \ || lastquote < g:java#format#length
        return v:null
    endif

    return {"left" : lastquote2, "right" : lastquote}
endfunction

function! s:BreakString(code,blength)
    let above = strpart(a:code,0,a:blength)
    let below = strpart(a:code,a:blength)
    return [above,below]
endfunction

function! java#format#format(code)
    let indices = s:QuoteByteIndices(a:code)
    let slength = indices.right - indices.left - 1
    let prefix = strpart(a:code,0,indices.left-1)
    let payload = strpart(a:code,indices.left+1,slength)
    let suffix = strpart(a:code,indices.right+1)
    " return [prefix,payload,suffix]
    return s:BreakString(payload,g:java#format#length - indices.left - 1)
endfunction
