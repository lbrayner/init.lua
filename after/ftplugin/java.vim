" delimitMate

" static snippets
abclear <buffer>
iabbrev <buffer> toStringm @Override<cr>public String
            \ toString()<cr>{<cr>}<up><right><cr>
inoreabbrev <buffer> tostr toStringm
iabbrev <buffer> sysout System.out.println();<left><left>
inoreabbrev <buffer> sysou sysout
inoreabbrev <buffer> syso sysout
iabbrev <buffer> syserr System.err.println();<left><left>
inoreabbrev <buffer> syser syserr
inoreabbrev <buffer> syse syserr
inoreabbrev <buffer> mainm public static void main(final String[] args)<cr>{<cr>}<up><cr>
inoreabbrev <buffer> staticm public static void ()<cr>{<cr>}<up><up><c-o>t(<right>
inoreabbrev <buffer> publicm public void ()<cr>{<cr>}<up><up><c-o>t(<right>
inoreabbrev <buffer> privatem private void ()<cr>{<cr>}<up><up><c-o>t(<right>
inoreabbrev <buffer> protectedm protected void ()<cr>{<cr>}<up><up><c-o>t(<right>
inoreabbrev <buffer> privates private static
inoreabbrev <buffer> publics public static
inoreabbrev <buffer> forl for()<cr>{<cr>}<up><up><c-o>f(<right>
inoreabbrev <buffer> whilel while()<cr>{<cr>}<up><up><c-o>f(<right>
inoreabbrev <buffer> iff if()<cr>{<cr>}<up><up><c-o>f(<right>
iabbrev <buffer> formats String.format("")<c-o>F"
inoreabbrev <buffer> fmt formats
inoreabbrev <buffer> info_ logger.info();<left><left>
inoreabbrev <buffer> debug_ logger.debug();<left><left>
inoreabbrev <buffer> error_ logger.error();<left><left>
inoreabbrev <buffer> blk {<cr>}<c-o>O
