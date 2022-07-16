if !has("nvim")
    finish
endif

function s:DiagnosticDefaults()
    highlight DiagnosticError ctermfg=1 guifg=Red
    highlight DiagnosticWarn  ctermfg=3 guifg=Orange
    highlight DiagnosticInfo  ctermfg=4 guifg=LightBlue
    highlight DiagnosticHint  ctermfg=7 guifg=LightGrey

	sign define DiagnosticSignError text=E texthl=DiagnosticSignError linehl= numhl=
	sign define DiagnosticSignWarn  text=W texthl=DiagnosticSignWarn  linehl= numhl=
	sign define DiagnosticSignInfo  text=I texthl=DiagnosticSignInfo  linehl= numhl=
	sign define DiagnosticSignHint  text=H texthl=DiagnosticSignHint  linehl= numhl=
endfunction

command! -nargs=0 DefaultDiagnostic call s:DiagnosticDefaults()

function s:CustomDiagnostic()
    highlight! def link DiagnosticInfo Ignore
    highlight! def link DiagnosticHint Comment

    sign define DiagnosticSignError text=Ɛ texthl=DiagnosticSignError linehl= numhl=
    sign define DiagnosticSignWarn  text=Ɯ texthl=DiagnosticSignWarn  linehl= numhl=
    sign define DiagnosticSignInfo  text=Ɩ texthl=DiagnosticSignInfo  linehl= numhl=
    sign define DiagnosticSignHint  text=ƕ texthl=DiagnosticSignHint  linehl= numhl=
endfunction

command! -nargs=0 CustomDiagnostic call s:CustomDiagnostic()

call s:CustomDiagnostic()
