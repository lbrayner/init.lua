function! s:GetVimDir()
    return util#GetComparableNodeName(g:vim_dir)
endfunction

function! extensions#ctrlp#ignore(item,type)
    if a:type ==# 'file'
        if has_key(g:extensions#ctrlp#ctrlp_custom_ignore,'file')
            if util#IsVimBundle()
                let vim_dir = s:GetVimDir()
                let file = g:extensions#ctrlp#ctrlp_custom_ignore.file
                return util#GetComparableNodeName(a:item) =~# file
            endif
            return a:item =~# g:extensions#ctrlp#ctrlp_custom_ignore.file
        endif
    endif
    if a:type ==# 'link'
        if has_key(g:extensions#ctrlp#ctrlp_custom_ignore,'link')
            return a:item =~# g:extensions#ctrlp#ctrlp_custom_ignore.link
        endif
    endif
    if a:type ==# 'dir'
        if has_key(g:extensions#ctrlp#ctrlp_custom_ignore,'dir')
            let dir = g:extensions#ctrlp#ctrlp_custom_ignore.dir
            if util#IsVimBundle()
                let vim_dir = s:GetVimDir()
                let dir .= '\V\|/\v(backup|pack|swap|undo)$'
                return util#GetComparableNodeName(a:item) =~# dir
            endif
            if util#IsEclipseProject()
                let dir .= '\v|[\/](classes|target|build|test-classes|dumps)$'
                return a:item =~# dir
            endif
            return a:item =~# g:extensions#ctrlp#ctrlp_custom_ignore.dir
        endif
    endif
    return 0
endfunction
