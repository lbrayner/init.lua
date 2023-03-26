function! statusline#StatusFlag()
    if &modified
        return "+"
    endif
    if !&modifiable
        return "-"
    endif
    if &readonly
        return "R"
    endif
    return " "
endfunction

function! statusline#Diagnostics()
    let buffer_severity = v:lua.require'lbrayner.diagnostic'.buffer_severity()
    if buffer_severity == v:null
        return "  "
    endif
    let group = "Diagnostic".buffer_severity[0].tolower(buffer_severity[1:])
    let cterm = synIDattr(synIDtrans(hlID(group)), "fg", "cterm")
    let gui = synIDattr(synIDtrans(hlID(group)), "fg", "gui")
    execute "highlight! User7 ctermfg=".cterm." guifg=".gui
    let prefix = v:lua.require'lbrayner.diagnostic'.get_prefix()
    return " %7*".prefix."%*"
endfunction

function! statusline#VersionControl()
    if !exists("*FugitiveHead")
        return ""
    endif
    let branch = FugitiveHead()
    if branch == ""
        return ""
    endif
    if len(branch) > 20
        return " " . FugitiveHead()[0:17]."..."
    endif
    return " " . FugitiveHead()
endfunction

function! s:GetLineFormat()
    if &buftype ==# "terminal"
        return "%".(len(&scrollback)+1)."l"
    endif
    let length = len(line("$"))
    if length < 5
        let length = 5
    endif
    return "%".length."l"
endfunction

function! s:GetNumberOfLines()
    if &buftype ==# "terminal"
        return "%".(len(&scrollback)+1)."L"
    endif
    let length = len(line("$"))
    if length < 5
        let length = 5
    endif
    return "%-".length."L"
endfunction

function! s:BufferPosition()
    return s:GetLineFormat() . ",%-3.v %3.P " . s:GetNumberOfLines()
endfunction

function! statusline#GetStatusLineTail()
    let bufferPosition = s:BufferPosition()
    " TODO remove this?
    if &buftype == "nofile"
        return bufferPosition . " %2*%{&filetype}%* "
    endif
    return bufferPosition
                \ . statusline#Diagnostics()
                \ . "%6*%{statusline#VersionControl()}%*"
                \ . " %4*%{util#Options('&fileencoding','&encoding')}%*"
                \ . " %4.(%4*%{&fileformat}%*%)"
                \ . " %2*%{&filetype}%* "
endfunction

function! statusline#Filename(...)
    let path = Path()
    if exists("*FPath") && stridx(expand("%"),"fugitive://") == 0
        let path = FPath()
    endif
    " jdtls
    if stridx(expand("%"),"jdt://") == 0
        let path = substitute(expand("%"), "?.*", "", "")
    endif
    if a:0 > 0 && a:1 " nofocus
        let filename=substitute(path,"'","''","g")
    else
        let filename = substitute(fnamemodify(path,":t"),"'","''","g")
    endif
    if filename == ""
        return "#".bufnr("%")
    endif
    return filename
endfunction

function! s:FugitiveTemporaryBuffer()
    return "Git ".join(FugitiveResult(bufnr()).args," ")
endfunction

" b:Statusline_custom_mod_leftline and b:Statusline_custom_mod_rightline are
" joined with %=

" margins of 1 column (on both sides)
" TODO is vim-fugitive information necessary here?
function! statusline#DefineModifiedStatusLine()
    let filename = statusline#Filename()
    if exists("b:Statusline_custom_mod_leftline")
        exec "let &l:statusline=' ".b:Statusline_custom_mod_leftline."'"
    " Fugitive summary
    elseif getbufvar(bufnr(),"fugitive_type") ==# "index"
        let &l:statusline=" "
        if &previewwindow
            let &l:statusline.="%5*Previewing:%* "
        endif
        let &l:statusline.="Fugitive summary%* %<%1 %{statusline#StatusFlag()}%*"
    " Fugitive blame
    elseif exists("*FugitiveResult") &&
                \has_key(FugitiveResult(bufnr()), "filetype") &&
                \has_key(FugitiveResult(bufnr()), "blame_file") &&
                \FugitiveResult(bufnr()).filetype == "fugitiveblame"
        let &l:statusline=" Fugitive blame %<%1*%{statusline#StatusFlag()}%*%="
        let &l:statusline.=s:BufferPosition()
        return
    " Fugitive temporary buffers
    elseif exists("*FugitiveResult") && len(FugitiveResult(bufnr()))
        let filename = s:FugitiveTemporaryBuffer()
        let &l:statusline=" "
        if &previewwindow
            let &l:statusline.="%5*Previewing%* "
        endif
        let &l:statusline.="%9*Fugitive:%* %<%1".filename." %{statusline#StatusFlag()}%*"
    elseif &previewwindow
        let &l:statusline = " %5*Previewing:%* "
        let &l:statusline.="%<%1*".filename." %{statusline#StatusFlag()}%*"
    else
        let &l:statusline=" %<%1*".filename." %{statusline#StatusFlag()}%*"
    endif
    let &l:statusline.=" %="
    if exists("b:Statusline_custom_mod_rightline")
        let &l:statusline.=b:Statusline_custom_mod_rightline
    endif
    let &l:statusline.=statusline#GetStatusLineTail()
endfunction

" margins of 1 column (on both sides)
function! statusline#DefineStatusLineNoFocus()
    if util#isQuickfixList()
        return
    endif
    let filename=statusline#Filename(1)
    let isnumbersonly=filename =~# '^[0-9]\+$'
    if isnumbersonly
        let &l:statusline=" ".filename." "
        return
    endif
    " Fugitive summary
    if getbufvar(bufnr(),"fugitive_type") ==# "index"
        let &l:statusline=" "
        if &previewwindow
            let &l:statusline.="Previewing: "
        endif
        let dir = substitute(util#NPath(FugitiveGitDir()),'/\.git$',"","")
        let &l:statusline.="Fugitive summary @ "
        let &l:statusline.=util#truncateFilename(dir,winwidth("%")-len(&statusline)-1)
        return
    endif
    " Fugitive objects
    if exists("*FugitiveParse") && len(FObject())
        let &l:statusline=" "
        if &previewwindow
            let &l:statusline.="Previewing: "
        endif
        let &l:statusline.=util#truncateFilename(FObject(),winwidth("%")-len(&statusline)-1)." "
        return
    endif
    " Fugitive blame
    if exists("*FugitiveResult") &&
                \has_key(FugitiveResult(bufnr()), "filetype") &&
                \has_key(FugitiveResult(bufnr()), "blame_file") &&
                \FugitiveResult(bufnr()).filetype == "fugitiveblame"
        let &l:statusline="Fugitive blame:"
        let filename = FugitiveResult(bufnr()).blame_file
        let filename = util#truncateFilename(filename,winwidth("%")-3-len(&l:statusline))
        let &l:statusline=" ".&l:statusline." ".filename." "
        return
    endif
    " Fugitive temporary buffers
    if exists("*FugitiveResult") && len(FugitiveResult(bufnr()))
        let cwd = fnamemodify(FugitiveResult(bufnr()).cwd,":p:~")
        let cwd = substitute(cwd,'/$',"","")
        let &l:statusline=" "
        if &previewwindow
            let &l:statusline.="Previewing "
        endif
        let &l:statusline.="Fugitive: "
        let &l:statusline.=util#truncateFilename(s:FugitiveTemporaryBuffer()." @ ".cwd,
                    \winwidth("%")-len(&statusline)-1)." "
        return
    endif
    if &previewwindow
        if expand("%") == ""
            let &l:statusline=" [Preview] %{statusline#StatusFlag()} "
        else
            let &l:statusline = " Previewing: "
            let filename = util#truncateFilename(
                        \statusline#Filename(1),
                        \winwidth("%")-len(&statusline)-1-(1+len(statusline#StatusFlag())))
            let &l:statusline.=filename." %{statusline#StatusFlag()} "
        endif
        return
    endif
    " TODO add statusline#StatusFlag where possible
    let filename = util#truncateFilename(statusline#Filename(1),
                \winwidth("%")-2-(1+len(statusline#StatusFlag())))
    let &l:statusline=" ".filename." %{statusline#StatusFlag()} "
endfunction

function! statusline#DefineTerminalStatusLine()
    let &l:statusline="%3*%=%*"
endfunction

" b:Statusline_custom_leftline and b:Statusline_custom_rightline are
" joined with %=

" margins of 1 column (on both sides)
function! statusline#DefineStatusLine()
    let filename = statusline#Filename()
    if exists("b:Statusline_custom_leftline")
        exec "let &l:statusline=' ".b:Statusline_custom_leftline."'"
    " Fugitive summary
    elseif getbufvar(bufnr(),"fugitive_type") ==# "index"
        let &l:statusline=" "
        if &previewwindow
            let &l:statusline.="%5*Previewing:%* "
        endif
        let &l:statusline.="Fugitive summary %<%1*%{statusline#StatusFlag()}%*"
    " Fugitive blame
    elseif exists("*FugitiveResult") &&
                \has_key(FugitiveResult(bufnr()), "filetype") &&
                \has_key(FugitiveResult(bufnr()), "blame_file") &&
                \FugitiveResult(bufnr()).filetype == "fugitiveblame"
        let &l:statusline=" Fugitive blame %<%1*%{statusline#StatusFlag()}%*%="
        let &l:statusline.=s:BufferPosition()
        return
    " Fugitive temporary buffers
    elseif exists("*FugitiveResult") && len(FugitiveResult(bufnr()))
        let filename = s:FugitiveTemporaryBuffer()
        let &l:statusline=" "
        if &previewwindow
            let &l:statusline.="%5*Previewing%* "
        endif
        let &l:statusline.="%9*Fugitive:%* %<".filename." %1*%{statusline#StatusFlag()}%*"
    elseif &previewwindow
        if expand("%") == ""
            let &l:statusline=" %<[Preview] %1*%{statusline#StatusFlag()}%*"
        else
            let &l:statusline=" %5*Previewing:%* %<".filename.
                        \" %1*%{statusline#StatusFlag()}%*"
        endif
    elseif util#isQuickfixList()
        let &l:statusline=" %<%5*%f%* %{util#getQuickfixTitle()}"
    elseif util#isLocationList()
        let &l:statusline=" %<%5*[Location List]%* %{util#getLocationListTitle(0)}"
    elseif getcmdwintype() != ""
        let &l:statusline = " %<%5*[Command Line]%*"
    elseif &buftype == "nofile"
        let &l:statusline=" %<%5*".filename." %1*%{statusline#StatusFlag()}%*"
    else
        let &l:statusline=" %<".filename." %1*%{statusline#StatusFlag()}%*"
    endif
    let &l:statusline.=" %="
    if exists("b:Statusline_custom_rightline")
        let &l:statusline.=b:Statusline_custom_rightline
    endif
    let &l:statusline.=statusline#GetStatusLineTail()
endfunction

function! statusline#Highlight(dict)
	for group in keys(a:dict)
        let arguments = a:dict[group]
        if type(arguments) == type({})
            for hikey in keys(arguments)
                exe "hi! ".group." ".s:term.hikey."=".arguments[hikey]
            endfor
        endif
        if type(arguments) == type("")
            exe "hi! ".group." ".s:term."=".arguments
        endif
    endfor
endfunction

function! statusline#HighlightMode(mode)
    exe "call statusline#Highlight({"
        \ . "'StatusLine': {'bg': s:".a:mode."_bg, 'fg': s:".a:mode."_fg},"
        \ . "'User1': {'bg': s:user1_".a:mode."_bg, 'fg': s:user1_".a:mode."_fg},"
        \ . "'User2': {'bg': s:user2_".a:mode."_bg, 'fg': s:user2_".a:mode."_fg},"
        \ . "'User3': {'bg': s:user3_".a:mode."_bg, 'fg': s:user3_".a:mode."_fg},"
        \ . "'User4': {'bg': s:user4_".a:mode."_bg, 'fg': s:user4_".a:mode."_fg},"
        \ . "'User5': {'bg': s:user5_".a:mode."_bg, 'fg': s:user5_".a:mode."_fg},"
        \ . "'User6': {'bg': s:user6_".a:mode."_bg, 'fg': s:user6_".a:mode."_fg},"
        \ . "'User7': {'bg': s:diagn_".a:mode."_bg},"
        \ . "'User9': {'bg': s:user9_".a:mode."_bg, 'fg': s:user9_".a:mode."_fg}})"
    exe "call statusline#Highlight({"
        \ . "'StatusLine': s:statusline_".a:mode.","
        \ . "'User1': s:statusline_".a:mode.","
        \ . "'User2': s:statusline_".a:mode.","
        \ . "'User3': s:statusline_".a:mode.","
        \ . "'User4': s:statusline_".a:mode.","
        \ . "'User5': s:statusline_".a:mode.","
        \ . "'User6': s:statusline_".a:mode.","
        \ . "'User7': s:statusline_".a:mode.","
        \ . "'User9': s:statusline_".a:mode."})"
endfunction

function! statusline#RedefineStatusLine()
    if &buftype == "terminal" && stridx(mode(), "t") == 0
        return
    endif
    " This variable is defined by the runtime.
    " :h g:actual_curwin
    if exists("g:actual_curwin") && g:actual_curwin != win_getid()
        return
    endif
    if &modified
        call statusline#DefineModifiedStatusLine()
    else
        call statusline#DefineStatusLine()
    endif
endfunction

function! statusline#loadColorTheme(colorMapping)
    let colorMapping = a:colorMapping
    if type(a:colorMapping) == type("")
        exec "let colorMapping = statusline#themes#".a:colorMapping."#getColorMapping()"
    endif
    for mapping in keys(colorMapping)
        let color = statusline#themes#getColor(colorMapping[mapping],s:term)
        exe "let s:".mapping."='".color."'"
    endfor
endfunction

function! statusline#loadTermAttrList(termAttrList)
    for mapping in keys(a:termAttrList)
        exe "let s:".mapping."='".a:termAttrList[mapping]."'"
    endfor
endfunction

function! statusline#getTerm()
    let term="cterm"
    if has("gui_running") || &termguicolors
        let term="gui"
    endif
    return term
endfunction

function! statusline#HighlightStatusLineNC()
    call statusline#Highlight({
        \ "StatusLineNC": {"bg": s:not_current_bg, "fg": s:not_current_fg}})
    exe "hi! StatusLineNC ".s:term."=".s:statuslinenc
endfunction

function! statusline#LoadTheme(colorTheme)
    if exists("*statusline#themes#".a:colorTheme."#getColorMapping")
        exec "source " . g:vim_dir . "/autoload/statusline/themes/".a:colorTheme.".vim"
    endif

    exec "let colorMapping = statusline#themes#".a:colorTheme."#getColorMapping()"
    exec "let termAttrList = statusline#themes#".a:colorTheme."#getTermAttrList()"

    call statusline#loadColorTheme(colorMapping)
    call statusline#loadTermAttrList(termAttrList)
    call statusline#HighlightMode("normal")
    call statusline#HighlightStatusLineNC()
endfunction

function! statusline#initialize()
    if !exists("g:Statusline_theme")
        let g:Statusline_theme = "default"
    endif

    call statusline#LoadTheme(g:Statusline_theme)
endfunction

let s:term = statusline#getTerm()
