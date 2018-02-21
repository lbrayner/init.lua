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
    if strlen(a:code) <= a:blength
        return [a:code]
    endif
    let above = strpart(a:code,0,a:blength)
    let below = strpart(a:code,a:blength)
    if above !~ '[^\\]\(\\\\\)\+$' && below =~ '^"'
        let above = strpart(above,0,strlen(above)-1)
        let below = '\' . below
    endif
    return [above] + s:BreakString(below,a:blength)
endfunction

function! s:AddQuotes(lines)
    call map(a:lines,"'\"'.v:val.'\"'")
endfunction

function! s:AddPlusSigns(lines)
    call map(a:lines,"'+'.v:val")
    return a:lines
endfunction

function! s:Indent(lines,ilength)
    call map(a:lines,"repeat(' ',".a:ilength.").v:val")
    return a:lines
endfunction

function! s:AssembleLines(prefix,suffix,lines)
    call s:AddQuotes(a:lines)
    let lines = a:lines[0:0] + s:AddPlusSigns(a:lines[1:])
    let lines = lines[0:0] + s:Indent(lines[1:],strlen(a:prefix)-1)
    let lines[0] = a:prefix . lines[0]
    let lines[len(lines)-1] = lines[len(lines)-1] . a:suffix
    return lines
endfunction

function! java#format#break_string(code)
    if strlen(a:code) <= g:java#format#length
        return a:code
    endif
    let indices = s:QuoteByteIndices(a:code)
    let slength = indices.right - indices.left - 1
    let prefix = strpart(a:code,0,indices.left-1)
    let payload = strpart(a:code,indices.left+1,slength)
    let suffix = strpart(a:code,indices.right+1)
    return s:AssembleLines(prefix,suffix
            \,s:BreakString(payload,g:java#format#length - indices.left - 1))
endfunction
