let g:java#format#length = 80

function! s:BreakString(code,blength)
    if strlen(a:code) <= a:blength
        return [a:code]
    endif
    let above = strpart(a:code,0,a:blength)
    let break_idx = strridx(above," ")
    if break_idx < 0
        let break_idx = a:blength
    endif
    let above = strpart(above,0,break_idx)
    let below = strpart(a:code,break_idx)
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

function! s:ShiftSpaces()
    return repeat(" ",shiftwidth())
endfunction

function! s:SpacesForTabs(code)
    return substitute(a:code,"\t",s:ShiftSpaces(),"g")
endfunction

function! s:AssembleLines(prefix,suffix,lines)
    call s:AddQuotes(a:lines)
    let lines = a:lines[0:0] + s:AddPlusSigns(a:lines[1:])
    let lines = lines[0:0] + s:Indent(lines[1:]
            \,strlen(substitute(a:prefix,"\t",s:ShiftSpaces(),"g"))-1)
    let lines[0] = a:prefix . lines[0]
    let lines[len(lines)-1] = lines[len(lines)-1] . a:suffix
    return lines
endfunction

function! java#format#break_string(code)
    let code = s:SpacesForTabs(a:code)
    if strlen(code) <= g:java#format#length
        return code
    endif
    let indices = format#QuoteByteIndices('\','"',code)
    let slength = indices.right - indices.left - 1
    let prefix = strpart(code,0,indices.left)
    let payload = strpart(code,indices.left+1,slength)
    let suffix = strpart(code,indices.right+1)
    return s:AssembleLines(prefix,suffix
            \,s:BreakString(payload,g:java#format#length - indices.left - 1 - 1))
endfunction

function! java#format#stringify() range
    silent exec "keepp ".a:firstline.",".a:lastline.'s/"/\\"/ge'
    if a:firstline == a:lastline
        silent exec "keepp ".a:firstline.",".a:firstline.'s/.*/"&"/e'
        return
    endif
    silent exec "keepp ".a:firstline.",".a:firstline.'s/.*/ "&"/e'
    silent exec "keepp ".(a:firstline+1).",".a:lastline.'s/.\+/+" &"/e'
endfunction
