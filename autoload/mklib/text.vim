" mklib.vim - another VimL non-standard library
" Maintainer: Martin Kopischke <http://martin.kopischke.net>
" License:    same as Vim (:h license)
" Version:    0.1.0

" Get character under cursor
function! mklib#text#curchar()
  return matchstr(getline('.'), '\%'.col('.').'c.')
endfunction

" Get character before the cursor
function! mklib#text#nextchar()
  return matchstr(getline('.'), '\%>'.col('.').'c.')
endfunction

" Get character after the cursor
function! mklib#text#prevchar()
  return matchstr(getline('.'), '.*\zs\%<'.col('.').'c.')
endfunction

" vim:set sw=2 sts=2 ts=8 et fdm=marker fdo+=jump fdl=1:
