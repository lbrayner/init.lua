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

function! s:ShiftSpaces()
    return repeat(" ",shiftwidth())
endfunction

function! s:SpacesForTabs(code)
    return substitute(a:code,"\t",s:ShiftSpaces(),"g")
endfunction

function! s:AddQuotes(quote,lines)
    call map(a:lines,'a:quote.v:val.a:quote')
endfunction

function! s:AddCatSigns(cat,lines)
    call map(a:lines,"v:val.a:cat")
    return a:lines
endfunction

function! s:Indent(lines,ilength)
    call map(a:lines,"repeat(' ',".a:ilength.").v:val")
    return a:lines
endfunction

function! s:AssembleLines(quote,cat,prefix,suffix,lines)
    call s:AddQuotes(a:quote,a:lines)
    let lines = s:AddCatSigns(a:cat,a:lines[0:-2]) + a:lines[-1:-1]
    let lines = lines[0:0] + s:Indent(lines[1:]
            \,strlen(substitute(a:prefix,"\t"
                \,s:ShiftSpaces(),"g")))
    let lines[0] = a:prefix . lines[0]
    let lines[len(lines)-1] = lines[len(lines)-1] . a:suffix
    return lines
endfunction

function! s:BreakString(code,blength)
    if strlen(a:code) <= a:blength
        return [a:code]
    endif
    let above = strpart(a:code,0,a:blength)
    let break_idx = strridx(above," ")
    if break_idx <= 0
        let break_idx = a:blength
    else
        let break_idx += 1
    endif
    let above = strpart(above,0,break_idx)
    let below = strpart(a:code,break_idx)
    if above !~ '[^\\]\(\\\\\)\+$' && below =~ '^"'
        let above = strpart(above,0,strlen(above)-1)
        let below = '\' . below
    endif
    return [above] + s:BreakString(below,a:blength)
endfunction

function! format#QuoteByteIndices(escape,quote,length,code)
    let lastquote = s:QuoteByteIndex(a:escape,a:quote,a:code)
    let lastquote2 = s:QuoteByteIndex(a:escape,a:quote,a:code,lastquote - 1)

    if lastquote < 0 || lastquote2 < 0
        return v:null
    endif

    if lastquote2 > a:length
                \ || lastquote < a:length
        return v:null
    endif

    return {"left" : lastquote2, "right" : lastquote}
endfunction

function! format#break_string(escape,quote,cat,length,code)
    let code = s:SpacesForTabs(a:code)
    if strlen(code) <= a:length
        return code
    endif
    let indices = format#QuoteByteIndices(a:escape,a:quote,a:length,code)
    let slength = indices.right - indices.left - 1
    let prefix = strpart(code,0,indices.left)
    let payload = strpart(code,indices.left+1,slength)
    let suffix = strpart(code,indices.right+1)
    return s:AssembleLines(a:quote,a:cat,prefix,suffix
            \,s:BreakString(payload,a:length - indices.left - 1 - 1))
endfunction
