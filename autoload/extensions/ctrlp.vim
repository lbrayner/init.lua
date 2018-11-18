function! extensions#ctrlp#ignore(item,type)
    if a:type ==# 'file'
        if has_key(g:extensions#ctrlp#ctrlp_custom_ignore,'file')
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
            if exists("g:vim_dir")
                let vim_dir = resolve(util#escapeFileName(g:vim_dir))
                let cwd = resolve(util#escapeFileName(getcwd()))
                if vim_dir ==# cwd
                    let dir = g:extensions#ctrlp#ctrlp_custom_ignore.dir
                    let dir .= '|(eclim|pack)$'
                    return a:item =~# dir
                endif
            endif
            return a:item =~# g:extensions#ctrlp#ctrlp_custom_ignore.dir
        endif
    endif
    return 0
endfunction
