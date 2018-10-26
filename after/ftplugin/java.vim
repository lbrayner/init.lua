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
iabbrev <buffer> formats String.format("")<c-o>F"
inoreabbrev <buffer> fmt formats
