" mappings
imapclear <buffer>
if exists('g:paredit_loaded')
    inoremap <buffer> <expr> " PareditInsertQuotes()
endif

" static snippets
abclear <buffer>
iabbrev <buffer> toString_ @Override<cr>public String toString()<cr>{<cr>}<up><cr>
inoreabbrev <buffer> tostr toString_
iabbrev <buffer> sysout System.out.println();<left><left>
inoreabbrev <buffer> sysou sysout
inoreabbrev <buffer> syso sysout
inoreabbrev <buffer> mainm public static void main(String[] args)<cr>{<cr>}<up><cr>
inoreabbrev <buffer> staticm public static void ()<cr>{<cr>}<cr><up><up><up><c-o>t(<right>
inoreabbrev <buffer> publicm public void ()<cr>{<cr>}<cr><up><up><up><c-o>t(<right>
inoreabbrev <buffer> privatem private void ()<cr>{<cr>}<cr><up><up><up><c-o>t(<right>
inoreabbrev <buffer> privates private static
inoreabbrev <buffer> publics public static
inoreabbrev <buffer> forl for()<cr>{<cr>}<cr><up><up><up><c-o>f(<right>
inoreabbrev <buffer> whilel while()<cr>{<cr>}<cr><up><up><up><c-o>f(<right>
inoreabbrev <buffer> iff if()<cr>{<cr>}<cr><up><up><up><c-o>f(<right>
iabbrev <buffer> formats String.format("");<c-o>F"
inoreabbrev <buffer> fmt formats
inoreabbrev <buffer> info_ logger.info();<left><left>
inoreabbrev <buffer> debug_ logger.debug();<left><left>
